extends BTLeaf

export (String) var source_property_blackboard_key := ""
export (String) var sub_property := ""
export (String) var sub_property_blackboard_key := ""

func tick(actor : Node, blackboard : Dictionary) -> int:
	var source = blackboard[source_property_blackboard_key]

	if not source:
		return STATE_FAILURE

	var sub_prop = source.get_indexed(sub_property)

	if not sub_prop:
		return STATE_FAILURE

	blackboard[sub_property_blackboard_key] = sub_prop
	return STATE_SUCCESS
