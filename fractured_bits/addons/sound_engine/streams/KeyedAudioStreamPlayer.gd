tool
extends AudioStreamPlayer
class_name KeyedAudioStreamPlayer

export (Resource) var keyed_sound_resource : Resource setget set_resource

func play_in_engine(from_pos := 0.0) -> void:
	SoundEngine.play_sound(self, from_pos)

func set_resource(value : Resource) -> void:
	var keyed := value as SoundWithKey
	if keyed:
		keyed_sound_resource = value
		self.stream = keyed.stream
		print("Loaded stream from keyed resource")
	else:
		keyed_sound_resource = null
		self.stream = null
		print("Requires resource of type 'SoundWithKey'")
