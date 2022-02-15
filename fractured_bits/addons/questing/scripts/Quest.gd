extends Resource
class_name Quest
"""
Quest

A resource class for storing the data for a quest object. 
"""
enum RequirementStyle{
	ALL, ANY, THRESHOLD
}

export (String) var quest_name := ""
export (String) var quest_description := ""
export (bool) var fail_on_cancelled := true
export (Array, String) var required_quests := []
export (RequirementStyle) var requirement_style : int
export (int) var requirement_threshold := 1

var enabled := false
var completed := false

signal on_quest_enabled
signal on_quest_cancelled(is_fail_state)
signal on_quest_completed

func enable_quest() -> void:
	enabled = true
	emit_signal("on_quest_enabled")

func complete_quest() -> void:
	completed = true
	emit_signal("on_quest_completed")

func cancel_quest() -> void:
	enabled = false
	emit_signal("on_quest_cancelled", fail_on_cancelled)
