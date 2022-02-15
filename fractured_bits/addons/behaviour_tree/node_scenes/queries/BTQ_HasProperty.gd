extends BTLeaf

export (String) var blackboard_key := "" 

func tick(actor : Node, blackboard : Dictionary) -> int:
	if blackboard.has(blackboard_key):
		return STATE_SUCCESS
	return STATE_FAILURE
