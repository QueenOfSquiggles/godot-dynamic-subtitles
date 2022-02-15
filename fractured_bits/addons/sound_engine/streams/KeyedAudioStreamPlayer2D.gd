tool
extends AudioStreamPlayer2D
class_name KeyedAudioStreamPlayer2D

export (Resource) var keyed_sound_resource : Resource setget set_resource

func play_in_engine(from_pos := 0.0) -> void:
	SoundEngine.play_sound2D(self, from_pos)

func set_resource(value : Resource) -> void:
	var keyed := value as SoundWithKey
	if keyed:
		keyed_sound_resource = value
		self.stream = keyed.stream
	else:
		keyed_sound_resource = null
		self.stream = null
		print("Requires resource of type 'SoundWithKey'")
