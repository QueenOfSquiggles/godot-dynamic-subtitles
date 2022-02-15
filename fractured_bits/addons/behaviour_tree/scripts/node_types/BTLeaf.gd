extends BTNode
class_name BTLeaf

func _ready() -> void:
	var num_children := get_child_count()
	assert(num_children <= 0, "BTLeaf node cannot have children!")

func tick(actor : Node, blackboard : Dictionary) -> int:
	print("Performing an action or performing a query")
	return STATE_SUCCESS
