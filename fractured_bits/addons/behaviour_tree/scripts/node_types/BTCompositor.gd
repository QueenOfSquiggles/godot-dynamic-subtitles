extends BTNode
class_name BTCompositor

enum Style {
	Sequence, Select
}

export (Style) var composite_style := Style.Sequence

func _ready() -> void:
	var num_children := get_child_count()
	assert(num_children > 1, "BTCompositor node requires more than one child!")

func tick(actor : Node, blackboard : Dictionary) -> int:
	var result := STATE_RUNNING
	for child in get_children():
		result = (child as BTNode).tick(actor, blackboard)
		if should_exit(result):
			return result
	return STATE_SUCCESS

func should_exit(state : int) -> bool:
	if state == STATE_RUNNING:
		return true
	if state == STATE_SUCCESS and composite_style == Style.Select:
		return true
	if state == STATE_FAILURE and composite_style == Style.Sequence:
		return true
	return false
