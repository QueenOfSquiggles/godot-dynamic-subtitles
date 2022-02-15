tool
extends EditorPlugin

const SOUND_ENGINE_SINGLETON := "SoundEngine"

func _enter_tree() -> void:
	add_autoload_singleton(SOUND_ENGINE_SINGLETON, "res://addons/sound_engine/autoload/SoundEngine.gd")
	
	var script := preload("res://addons/sound_engine/sound_lib/SoundLib.gd")
	var script2D := preload("res://addons/sound_engine/sound_lib/SoundLib2D.gd")
	var script3D := preload("res://addons/sound_engine/sound_lib/SoundLib3D.gd")
	var music_note := preload("res://addons/sound_engine/icons/sound_lib.svg")
	var music_note2D := preload("res://addons/sound_engine/icons/sound_lib_2D.svg")
	var music_note3D := preload("res://addons/sound_engine/icons/sound_lib_3D.svg")
	

	add_custom_type("SoundLib", "Node", script, music_note)
	add_custom_type("SoundLib2D", "Node2D", script2D,music_note2D)
	add_custom_type("SoundLib3D", "Spatial", script3D,music_note3D)
	
	var keyed := preload("res://addons/sound_engine/streams/KeyedAudioStreamPlayer.gd")
	var keyed2D := preload("res://addons/sound_engine/streams/KeyedAudioStreamPlayer2D.gd")
	var keyed3D := preload("res://addons/sound_engine/streams/KeyedAudioStreamPlayer3D.gd")
	add_custom_type("KeyedAudioStreamPlayer", "AudioStreamPlayer", keyed, music_note)
	add_custom_type("KeyedAudioStreamPlayer2D", "AudioStreamPlayer2D", keyed2D, music_note2D)
	add_custom_type("KeyedAudioStreamPlayer3D", "AudioStreamPlayer3D", keyed3D, music_note3D)

func _exit_tree() -> void:
	remove_custom_type("SoundLib")
	remove_custom_type("SoundLib2D")
	remove_custom_type("SoundLib3D")
	remove_custom_type("KeyedAudioStreamPlayer")
	remove_custom_type("KeyedAudioStreamPlayer2D")
	remove_custom_type("KeyedAudioStreamPlayer3D")
	remove_autoload_singleton(SOUND_ENGINE_SINGLETON)
