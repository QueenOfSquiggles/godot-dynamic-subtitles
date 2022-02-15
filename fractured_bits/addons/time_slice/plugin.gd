tool
extends EditorPlugin

const TIME_SLICE_AUTOLOAD_NAME := "TimeSlice"

func _enter_tree() -> void:
	add_autoload_singleton(TIME_SLICE_AUTOLOAD_NAME, "res://addons/time_slice/TimeSlice.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(TIME_SLICE_AUTOLOAD_NAME)
