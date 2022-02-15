extends Node
class_name BTNode

const STATE_SUCCESS := 0
const STATE_FAILURE := 1
const STATE_RUNNING := 1


func tick(actor : Node, blackboard : Dictionary) -> int:
	return STATE_SUCCESS
