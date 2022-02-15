extends BTLeaf

export (String) var group_id := ""
export (String) var blackboard_key := ""

func tick(actor : Node, blackboard : Dictionary) -> int:
	var group :Array = get_tree().get_nodes_in_group(group_id)
	if group.empty():
		return STATE_FAILURE # fail if none are found
	# also only assign to blackboard if there are elements in array
	# let other nodes handle missing vars? <-- maybe that's bad?
	blackboard[blackboard_key] = group
	return STATE_SUCCESS # succeed if at least one is found
