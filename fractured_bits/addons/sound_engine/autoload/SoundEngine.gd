extends Node

signal on_sound_played(stream_player, sound_key)

const DEFAULT_SOUND_KEY := "_"

func play_sound(stream_player : AudioStreamPlayer, from_pos = 0.0) -> void:
	"""
	Running play calls through this function processes the sound as normal, but also checks to see if it is using a keyed sound. It then emits a signal with the attached key and the stream player, if there is no attached key, the DEAFULT_SOUND_KEY is provided. 
	This system is intended to be used alongside a subtitles system or anything else that needs to pay attention to what sounds are being played like in a stealth game
	"""
	stream_player.play(from_pos)
	var kasp := stream_player as KeyedAudioStreamPlayer
	var key := DEFAULT_SOUND_KEY
	if kasp:
		key = (kasp.keyed_sound_resource as SoundWithKey).sound_key
	emit_signal("on_sound_played", stream_player, key)

func play_sound2D(stream_player : AudioStreamPlayer2D, from_pos = 0.0) -> void:
	"""
	2d version of play_sound
	"""
	stream_player.play(from_pos)
	var kasp := stream_player as KeyedAudioStreamPlayer2D
	var key := DEFAULT_SOUND_KEY
	if kasp:
		key = (kasp.keyed_sound_resource as SoundWithKey).sound_key
	emit_signal("on_sound_played", stream_player, key)

	
func play_sound3D(stream_player : AudioStreamPlayer3D, from_pos = 0.0) -> void:
	"""
	3d version of play_sound
	"""
	stream_player.play(from_pos)
	var kasp := stream_player as KeyedAudioStreamPlayer3D
	var key := DEFAULT_SOUND_KEY
	if kasp:
		key = (kasp.keyed_sound_resource as SoundWithKey).sound_key
	emit_signal("on_sound_played", stream_player, key)

