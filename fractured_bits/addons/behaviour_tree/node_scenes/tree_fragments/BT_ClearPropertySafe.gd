extends BTCompositor

export (String) var blackboard_key := "" setget set_key

onready var has_prop := $BT_Decorator/BTQ_HasProperty
onready var clear_prop := $BT_ClearProperty

func set_key(key : String) -> void:
	blackboard_key = key
	has_prop.blackboard_key = key
	clear_prop.blackboard_key = key

