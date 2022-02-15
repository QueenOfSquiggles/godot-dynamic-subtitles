extends BTLeaf

export (String) var blackboard_key := ""

func tick(actor : Node, blackboard : Dictionary) -> int:
	blackboard.erase(blackboard_key)
	return STATE_SUCCESS
