extends BTLeaf
"""
Gotta be perfectly honest. I can't understand where I would use this in a game, but there are people much smarter than me with much more advanced systems in their games so maybe this will serve some purpose in their game/project
"""

export (String) var resource_path := ""
export (bool) var load_immediate := false
export (String) var blackboard_key := ""
export (int) var max_ms_per_poll := 5

var loader : ResourceInteractiveLoader = null

func tick(actor : Node, blackboard : Dictionary) -> int:
	if load_immediate:
		# loads in immediately. Good for small resources that won't make a hitch
		var res := load_instant()
		if res == null:
			return STATE_FAILURE
		blackboard[blackboard_key] = res
		return STATE_SUCCESS
	else:
		# loads the resource in slowly, attempting to keep the polling time around the desired number of milliseconds. 
		var result := load_progressive()
		if not result:
			return STATE_RUNNING
		blackboard[blackboard_key] = result
	return STATE_SUCCESS

func load_instant() -> Resource:
	var res := load(resource_path)
	return res

func load_progressive() -> Resource:
	if not loader:
		loader = ResourceLoader.load_interactive(resource_path)
	var start_time := OS.get_system_time_msecs()
	var now := start_time
	while (now - start_time) < max_ms_per_poll:
		var err := loader.poll()
		if err == ERR_FILE_EOF: 
			return loader.get_resource()
		now = OS.get_system_time_msecs()
	return null
