extends Spatial

export (Resource) var test_sample_with_key : Resource

onready var sampled_keyed := test_sample_with_key as SoundWithKey
var spatial_test_nodes := []

func _ready() -> void:
	SoundEngine.connect("on_sound_played", self, "process_sound")
	_create_spatial_test()

func process_sound(stream, key : String) -> void:
	# This is basically all that's needed to connect the sound engine and subtitles systems. This could be made into an autoload to make this happen for all scenes
	if key != SoundEngine.DEFAULT_SOUND_KEY:
		Subtitles.create_subtitle(stream, key)

func _create_spatial_test() -> void:
	if not sampled_keyed:
		push_warning("failed to load audio stream with key resource")
		return
	var cam :Spatial= $"Spatial/FreeLookCam"
	var increment := 5
	var distance := 10.0
	var range_test := range(-increment, increment)
	for x in range_test:
		for z in range_test:
			var pos := Vector3(x, 0, z).normalized() * distance
			var sample := KeyedAudioStreamPlayer3D.new()
			add_child(sample)
			sample.global_transform.origin = cam.global_transform.origin + pos
			sample.keyed_sound_resource = sampled_keyed
			sample.time_padding = 5.0
			spatial_test_nodes.append(sample)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		play_spatial_test()

func play_spatial_test() -> void:
	for s in spatial_test_nodes:
		var player := s as KeyedAudioStreamPlayer3D
		player.play_in_engine()
