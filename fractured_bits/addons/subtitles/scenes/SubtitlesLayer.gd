extends CanvasLayer
"""
Subtitles (SubtitlesLayer.gd)

see 'create_subtitle' for core functionality

This node is a canvas layer autoload so the layer this renders on can be customized. I.e. if you want the subtitles to be behind some kind of detail layer, that's possible. IN general it is recommended to put subtitles as top-layer as possible.

"""

# TODO refactor this whole script. Functions need to be reorganized, maybe even refactored out to make it more readable. Add comments to remember what's happening here, etc... Make this maintainable by people who aren't me -squigz

var subtitle_theme :Theme = preload("res://addons/subtitles/default_theming/base_theme.tres") # set this to customize
var subtitle_padding_min := Vector2(20,20)
var subtitle_padding_max := Vector2(20,20)
var character_line_width_percent := 0.7
var default_subtitle_position := Vector2(50, 2000) # use really big y to clamp to bottom
# would be nice to be able to set some kind of alignment/anchoring that is customizable


var _stream_mapping := {}
var _cache_viewport_size := Vector2()

var _sub_id_counter := 0

onready var _char_subtitles := VBoxContainer.new()
onready var _spatial_subtitles_left := VBoxContainer.new()
onready var _spatial_subtitles_right := VBoxContainer.new()

func _ready() -> void:
	# char subtitles : full screen, start stack at bottom
	# used for non-spatial subtitles specifically intended for character dialogue, but could be used for any non-spatial subtitle
	add_child(_char_subtitles)
	_char_subtitles.alignment = BoxContainer.ALIGN_END
	_char_subtitles.set_anchors_preset(Control.PRESET_WIDE, true)
	_char_subtitles.name = "panel_character_dialogue"

	# spatial subs left : left & tall, fill from center
	# used for spatial subtitles that go off screen to the left. Currently only works for 3D spatial subtitles
	add_child(_spatial_subtitles_left)
	_spatial_subtitles_left.alignment = BoxContainer.ALIGN_CENTER
	_spatial_subtitles_left.set_anchors_preset(Control.PRESET_LEFT_WIDE, true)
	_spatial_subtitles_left.name = "spatial_subs_left"

	# spatial subs left : left & tall, fill from center
	# used for spatial subtitles that go off screen to the left. Currently only works for 3D spatial subtitles
	add_child(_spatial_subtitles_right)
	_spatial_subtitles_right.alignment = BoxContainer.ALIGN_CENTER
	_spatial_subtitles_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE, true)
	_spatial_subtitles_right.name = "spatial_subs_right"
	

func _process(delta: float) -> void:
	# cache viewport size, we might be using this Vector2 thousands of times per frame if there's enough subtitles
	var viewport := get_tree().current_scene.get_viewport()
	_cache_viewport_size = viewport.size
	# update spatial subtitles to correct positioning
	# TODO : allow for some kind of time slicing? This doesn't NEED to happen ever frame. It could even run at 20 fps or so without too big of a noticeable effect which would reduce computations
	
	# moving off of sidebar should be done first because the sidebar will automatically manage position, but main group has to be repositioned manually
	_process_sidebar_subtitles() # any side-bar subtitles now "on-screen" -> eject to the main group
	for c in get_children():
		if _stream_mapping.has(c.name):
			var stream = _stream_mapping[c.name]
			_update_subtitle(c, stream) # fix spatial position, move to sidebar if off-screen
	_spatial_subtitles_right.rect_position.x = _cache_viewport_size.x - _spatial_subtitles_right.rect_size.x
	_spatial_subtitles_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE, true)
	_spatial_subtitles_right.alignment = BoxContainer.ALIGN_CENTER


func _process_sidebar_subtitles() -> void:
	# go through sidebar subtitles and see if they need to be moved
	_process_sidebar(_spatial_subtitles_left)
	_process_sidebar(_spatial_subtitles_right)

func _process_sidebar(box : VBoxContainer) -> void:
	for c in box.get_children():
		if not is_instance_valid(c):
			# skip invalid children
			continue
		if _stream_mapping.has(c.name):
			var stream = _stream_mapping[c.name]
			var pos := _subtitle_3d(stream, c)
			if pos.x > subtitle_padding_min.x and pos.x < _cache_viewport_size.x - subtitle_padding_max.x:
				# predicted screen position is on-screen, move to on-screen spatial group
				_reparent_sub(c, box, self)
		else:
			push_warning("Detected invalid subtitle on sidebar! " + c.name + " -> " + str(_stream_mapping))

func _reparent_sub(subtitle : PanelContainer, current_parent : Node, destination_parent : Node) -> void:
	subtitle.disconnect("tree_exiting", self, "_clear_mapping") # prevent this from triggering wher reparenting
	current_parent.remove_child(subtitle)
	destination_parent.add_child(subtitle)
	subtitle.connect("tree_exiting", self, "_clear_mapping", [subtitle]) # reconnect for cleanup


func _update_subtitle(panel : PanelContainer, stream) -> void:
	var pos = panel.rect_position
	if stream is AudioStreamPlayer3D:
		pos = _subtitle_3d(stream, panel)
		if pos.x < 0:
			# from main group to left sidebar
			_reparent_sub(panel, self, _spatial_subtitles_left)
		if pos.x > _cache_viewport_size.x:
			# from main group to right sidebar
			_reparent_sub(panel, self, _spatial_subtitles_right)
		pos = _fix_position(pos, panel)
	if panel.get_parent() == self:
		# only update the rect position if this is a direct child of the layer node
		# this way subtitles move to sidebars in this step don't get messed with
		panel.rect_position = pos

func create_subtitle(stream, key : String, override_theme : Theme = null) -> void:
	"""
	The main function for loading subtitles for something. Everything is functionally handled automatically. The plugin autoloads the render layer and the sound data can be passed easily using a KeyedAudioStreamPlayer. This isn't intended to be a very complex implementation for subtitles, but a solution that "just works" and is simple enough to use for a Jam game.
	Currently positional audio subtitles are only supported for 3D environments. 2D has yet to be implemented because I mostly develop for 3D. Also 2D environments might benefit less from positional subtitles
	Params:
		'stream': the AudioStreamPlayer (or 2D, 3D variants)
		'key': the subtitle key. If it includes a ':' it is assumed to be a character dialogue and the first half is treated as the character's name while the remaining is treated as the actual subtitle key
		'override_theme': an optional override theme for special use cases
	"""
	
	# TODO convert this system to handle a custom node-child containing subtitle data as opposed to requiring use of my KeyedAudioStreamPlayer
	var pos := default_subtitle_position
	var panel := _subtitle_obj(key)
	var time_remaining := 1.0
	var theme := subtitle_theme
	if override_theme:
		theme = override_theme
	if stream is AudioStreamPlayer3D:
		pos = _subtitle_3d(stream, panel)
		pos = _fix_position(pos, panel) # fix pos either way to fix erronous default positions
		# maybe should I change this to use a timer that waits the expected length of the sound? That would fix this and prevent the gradual build-up of subtitles
		time_remaining = (stream as AudioStreamPlayer3D).stream.get_length()
	if "time_padding" in stream:
		# this checks if a node has a certain property
		time_remaining += stream.time_padding
	if "subtitle_theme" in stream:
		if stream.subtitle_theme != null:
			theme = stream.subtitle_theme
	panel.rect_position = pos
	var timer := Timer.new()
	panel.add_child(timer)
	timer.connect("timeout", panel, "queue_free")
	timer.start(time_remaining)
	_stream_mapping[panel.name] = stream
	panel.connect("tree_exiting", self, "_clear_mapping", [panel])
	if subtitle_theme:
		panel.theme = theme

func _get_dot_angle(camera: Camera, audio_source : Spatial) -> float:
	var cam_dir := -camera.global_transform.basis.z
	var delta_pos :Vector3 = audio_source.global_transform.origin - camera.global_transform.origin
	var vec_a := Vector2(cam_dir.x, cam_dir.z).normalized()
	var vec_b := Vector2(delta_pos.x, delta_pos.z).normalized()
	return vec_a.angle_to(vec_b)

func _clear_mapping(panel : PanelContainer) -> void:
	_stream_mapping.erase(panel.name)

func _subtitle_3d(stream :KeyedAudioStreamPlayer3D, panel : PanelContainer) -> Vector2:
	if not stream.handle_position:
		# if not set to positional sound, place in default position
		return default_subtitle_position
	var viewport := get_tree().current_scene.get_viewport()
	var cam :Camera= viewport.get_camera()
	var pos3D := stream.transform.origin
	var angle := _get_dot_angle(cam, stream)
		
	var result := cam.unproject_position(stream.global_transform.origin)
	if abs(angle) > deg2rad(cam.fov * 0.9):
	#if cam.is_position_behind(pos3D):
		#result.y = cache viewport.size.y # force to bottom of screen
		result.x = viewport.size.x - result.x
		if angle < 0:
			result.x = -10
		else:
			result.x = viewport.size.x + 10
		# exaggerate the off-screen levels for off-screen detection to be easier
			
	return result

func _fix_position(pos : Vector2, panel : PanelContainer) -> Vector2:
	var result := pos
	var viewport := get_tree().current_scene.get_viewport()
	
	var min_ := Vector2(0, 0)
	var max_ := Vector2(viewport.size.x, viewport.size.y) - panel.rect_size
	min_ += subtitle_padding_min
	max_ -= subtitle_padding_max
	
	result.x = clamp(pos.x, min_.x, max_.x)
	result.y = clamp(pos.y, min_.y, max_.y)
	return result

func _subtitle_obj(key : String) -> PanelContainer:
	if key.find(":") != -1:
		var arr := key.split(":", false, 1)
		if arr.size() == 2:
			return _subtitle_obj_char(arr[0], arr[1])
		else:
			push_warning("had a false positive on key [%s]" % key)
	var panel := PanelContainer.new()
	var label := Label.new()
	label.text = key
	panel.add_child(label)
	panel.name = "Sub_" + key
	panel.name = _get_next_subtitle_id(panel.name)
	self.add_child(panel)
	return panel

func _subtitle_obj_char(char_name : String, key : String) -> PanelContainer:
	var viewport := get_tree().current_scene.get_viewport()
	var panel := PanelContainer.new()
	var vbox := VBoxContainer.new()
	var lbl_name := Label.new()
	var lbl_text := Label.new()
	lbl_name.text = char_name
	lbl_text.text = key
	lbl_text.autowrap = true
	lbl_text.rect_min_size.x = viewport.size.x * character_line_width_percent
	vbox.add_child(lbl_name)
	vbox.add_child(lbl_text)
	panel.add_child(vbox)
	panel.name = "Sub_" + char_name + "_" + key
	panel.name = _get_next_subtitle_id(panel.name)
	panel.anchor_left = 0.5
	_char_subtitles.add_child(panel)
	return panel

func _get_next_subtitle_id(name : String) -> String:
	_sub_id_counter += 1
	_sub_id_counter %= 999
	return name + str(_sub_id_counter).pad_zeros(3)
