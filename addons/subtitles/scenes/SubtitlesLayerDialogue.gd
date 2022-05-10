extends CanvasLayer
class_name SubtitlesLayerDialogue
"""
SubtitlesLayerDialogue
---
A subtitles layer for the character dialogue and any non-spatial subtitles that are crucial for the player to read


"""
const SETTING_AUTO_LINE_SPLIT := "Subtitles/General/use_auto_dialogue_line_splitter"
const SETTING_AUTO_LINE_SPLIT_REGEX := "Subtitles/Advanced/auto_line_splitter_regular_expression"

var use_auto_line_splitter := true
var auto_split_regex := ""
var max_tokens_per_line_range := 15 # missing project settings
var max_stack_size := 3 # missing project settings

class Dialogue:
	var stream_node : Node
	var sub_data : SubtitleData
	var override_text : String = ""
	var theme_override : Theme
	
	func _init(sn : Node, sd : SubtitleData, to : Theme = null) -> void:
		stream_node = sn
		sub_data = sd
		theme_override = to

var side_padding := 20
var bottom_padding := 5

var _dialogue_queue := []
onready var _dialogue_stack := VBoxContainer.new()

func _ready() -> void:
	use_auto_line_splitter = ProjectSettings.get_setting(SETTING_AUTO_LINE_SPLIT)
	auto_split_regex = ProjectSettings.get_setting(SETTING_AUTO_LINE_SPLIT_REGEX)
	add_child(_dialogue_stack)
	_dialogue_stack.set_anchors_and_margins_preset(Control.PRESET_WIDE) # fill screen
	_dialogue_stack.alignment = BoxContainer.ALIGN_END
	_dialogue_stack.margin_left = side_padding
	_dialogue_stack.margin_right = -side_padding
	_dialogue_stack.margin_bottom = -bottom_padding
	_dialogue_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dialogue_stack.theme = Subtitles.default_subtitle_theme

func add_subtitle(stream_node : Node, sub_data : SubtitleData, theme_override : Theme = null) -> void:
	if not use_auto_line_splitter:
		_dialogue_queue.append(Dialogue.new(stream_node, sub_data, theme_override))
	else:
		var parts := _parse_subtitle_lines(sub_data)
		#print("parts=%s" % str(parts))
		for p in parts.values(): # parts should be an dict of string tokens, representing the dialogue as a whole
			var text := p["text"] as String
			var token_count := p["token_count"] as int
			var n_sub_data := sub_data.duplicate() as SubtitleData
			n_sub_data.subtitles_padding = float(token_count) * 0.5 # BBC says 0.33 seconds per word, but this is a better buffer for video games I think
			var dia := Dialogue.new(stream_node, n_sub_data, theme_override)
			dia.override_text = text
			_dialogue_queue.append(dia)
	_refresh_stack()

func _parse_subtitle_lines(sub_data : SubtitleData) -> Dictionary:
	if not use_auto_line_splitter:
		return {}
		
	var full_text := tr(sub_data.subtitle_key)
	var regEx := RegEx.new()
	regEx.compile(auto_split_regex)
	var elements := _regex_split(full_text, regEx)
	#print("elements=%s" % str(elements))
	#print("Total tokens in dialogue : %s" % str(elements.size()))

	var counter := 0
	var current_line := ""
	var parts := {}
	var element_num := 0
	for token in elements:
		current_line += token
		counter += 1
		if counter >= max_tokens_per_line_range:
			parts[element_num] = {
				"text" : current_line,
				"token_count" : counter
				}
			current_line = ""
			counter = 0
			element_num += 1
	parts[element_num] = { # chain the final tokens that were left behind by the loop
		"text" : current_line,
		"token_count" : counter
		}	
	return parts

func _regex_split(input : String, regEx : RegEx) -> Array:
	# basically tokenizes the string based on a regex matching split function
	var segments := []
	var matches := regEx.search_all(input)
	var last_start := 0
	for m in matches:
		var reg_match := m as RegExMatch
		#print("RegMatch found: %s" % str(reg_match.names))
		var length := reg_match.get_start() - last_start
		segments.append(input.substr(last_start, length))
		last_start = reg_match.get_start()
	segments.append(input.substr(last_start))
	return segments

func _refresh_stack() -> void:
	if (not _dialogue_queue.empty()) and (_dialogue_stack.get_child_count() < max_stack_size):
		# add subtitle to stack
		var dialogue := _dialogue_queue.pop_front() as Dialogue
		var sub := _create_sub(dialogue.sub_data, dialogue.override_text)
		if not sub:
			return
		_dialogue_stack.add_child(sub)
		_create_subtitle_timer(sub, dialogue.stream_node, dialogue.sub_data)
		sub.connect("tree_exited", self, "_refresh_stack", [], CONNECT_DEFERRED) # one frame after it exits the tree, refresh the stack again
		if dialogue.theme_override != null:
			sub.theme = dialogue.theme_override
		if (_dialogue_stack.get_child_count() < max_stack_size):
			call_deferred("_refresh_stack")

func _create_sub(sub_data : SubtitleData, override_text : String) -> PanelContainer:
	if not is_instance_valid(sub_data):
		return null
	var panel := PanelContainer.new()
	var key := sub_data.subtitle_key
	if key.find(":") != -1:
		# treat as character dialogue, 3D positional
		var vbox := VBoxContainer.new()
		var lbl_name := Label.new()
		var lbl_text := Label.new()
		var parts := key.split(":", false, 1)
		lbl_name.text = parts[0] as String
		lbl_text.text = parts[1] as String
		lbl_text.autowrap = true
		vbox.add_child(lbl_name)
		vbox.add_child(lbl_text)
		panel.add_child(vbox)
	else:
		# treat as general subtitle
		var label := Label.new()
		label.text = sub_data.subtitle_key
		if not override_text.empty():
			label.text = override_text
		panel.add_child(label)
	_create_panel_name(panel, sub_data)
	return panel

func _create_subtitle_timer(panel : PanelContainer, audio : Node, sub_data : SubtitleData) -> void:
	var timer := Timer.new()
	panel.add_child(timer)
	timer.wait_time = max(audio.stream.get_length() + sub_data.subtitles_padding, 0.001) # make sure the wait time doesn't go negative
	timer.connect("timeout", panel, "queue_free")
	timer.start()

var _subtitle_id :int= 0 # this is tucked here because it is only used here
func _create_panel_name(panel : PanelContainer, sub_data : SubtitleData) -> void:
	# sets the subtitle's name to be something like "Sub3D_key_023"
	# the ID is not specific to any one key since there could be thousands of keys. It just heavily decreases the potential for any two suibtitles having the same name, which results in a garbage-looking name generated by Godot
	panel.name = "SubCharacter_" + sub_data.subtitle_key + "_" + str(_subtitle_id).pad_zeros(3)
	_subtitle_id += 1
	_subtitle_id %= 999

func _process(delta: float) -> void:
	self.name = str(self.name) # dummy process to ensure soemthing happens

func clear() -> void:
	set_visible(false)
	for c in _dialogue_stack.get_children():
		c.queue_free()
		_dialogue_stack.remove_child(c)

func set_visible(is_visible : bool) -> void:
	for c in _dialogue_stack.get_children():
		if c is Control:
			(c as Control).visible = is_visible
