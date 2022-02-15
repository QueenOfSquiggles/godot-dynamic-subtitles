extends BTLeaf

export (String) var group_array_blackboard_key := ""
export (float) var min_distance := 0.0
export (float) var max_distance := 100.0
export (String) var closest_node_blackboard_key := ""


func tick(actor : Node, blackboard : Dictionary) -> int:
	if not blackboard.has(group_array_blackboard_key):
		# flag an assert because this is likely not desired.
		# Obviously if this is desired functionality, remove the assertion
		assert(false, "Failed to find group assigned in the blackboard. This isn't broken, but likely unexpected")
		return STATE_FAILURE
	var group :Array = blackboard[group_array_blackboard_key]
	var closest : Node = null
	# handle distance regardless of dimension we are processing in.
	# A seperate node could be made for each, but the logic is so similar it feels wrong to seperate into 3 different nodes
	if actor is Node2D:
		closest = get_closest_2D(actor, group)

	elif actor is Spatial:
		closest = get_closest_3D(actor, group)

	elif actor is Control:
		closest = get_closest_UI(actor, group)

	if closest == null:
		# if after the search the closest is null, fail
		return STATE_FAILURE

	# only assigns if the result is non-null.
	# that was a HasProperty node will succeed if there is a closest node, allowing for skipping entire branches if there isn't a current closest node.		
	blackboard[closest_node_blackboard_key] = closest
	# didn't fail so succeed
	return STATE_SUCCESS

func get_closest_2D(actor : Node2D, group : Array) -> Node:
	var distance := max_distance
	var result : Node2D = null
	for node in group:
		if node is Node2D:
			var dist = _distance_2D(actor, node)
			if dist < distance and dist > min_distance:
				result = node as Node2D
				distance = dist
	return result

func get_closest_3D(actor : Spatial, group : Array) -> Node:
	var distance := max_distance
	var result : Spatial = null
	for node in group:
		if node is Spatial:
			var dist = _distance_3D(actor, node)
			if dist < distance and dist > min_distance:
				result = node as Spatial
				distance = dist
	return result

func get_closest_UI(actor : Control, group : Array) -> Node:
	var distance := max_distance
	var result : Control = null
	for node in group:
		if node is Control:
			var dist = _distance_UI(actor, node)
			if dist < distance and dist > min_distance:
				result = node as Control
				distance = dist
	return result




func _distance_2D(actor : Node2D, other : Node2D) -> float:
	var delta : Vector2 = actor.position - other.position
	return delta.length()

func _distance_3D(actor : Spatial, other : Spatial) -> float:
	var delta : Vector3 = actor.transform.origin - other.transform.origin
	return delta.length()
	
func _distance_UI(actor : Control, other : Control) -> float:
	# Is this even required?
	var delta : Vector2 = actor.rect_position - other.rect_position
	return delta.length()
