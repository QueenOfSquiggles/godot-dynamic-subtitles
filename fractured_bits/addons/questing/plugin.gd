tool
extends EditorPlugin

const SINGLETON := "QuestManager"

func _enter_tree() -> void:
	add_autoload_singleton(SINGLETON, "res://addons/questing/scripts/QuestManager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(SINGLETON)
