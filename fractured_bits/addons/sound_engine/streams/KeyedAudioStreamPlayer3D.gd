tool
extends AudioStreamPlayer3D
class_name KeyedAudioStreamPlayer3D

export (Resource) var keyed_sound_resource : Resource setget set_resource
export (bool) var handle_position := true
export (float) var time_padding := 0.0
export (Theme) var subtitle_theme :Theme = null

func play_in_engine(from_pos := 0.0) -> void:
	SoundEngine.play_sound3D(self, from_pos)

func set_resource(value : Resource) -> void:
	var keyed := value as SoundWithKey
	if keyed:
		keyed_sound_resource = value
		self.stream = keyed.stream
	else:
		keyed_sound_resource = null
		self.stream = null
		print("Requires resource of type 'SoundWithKey'")
