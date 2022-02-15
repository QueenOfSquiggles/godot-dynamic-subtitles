tool
extends EditorPlugin

const SINGLETON := "Subtitles"

func _enter_tree() -> void:
	add_autoload_singleton(SINGLETON, "res://addons/subtitles/scenes/SubtitlesLayer.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(SINGLETON)
