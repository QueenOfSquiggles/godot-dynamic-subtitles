extends BTNode
class_name BTDecorator

enum Style {
	Inverter, Succeeder, Limiter
}

export (Style) var decorate_style := Style.Inverter

export (int) var limit := 0
var counter := 0

func _ready() -> void:
	var num_children := get_child_count()
	assert(num_children == 1, "BTDecorator node requires exactly one child!")

func tick(actor : Node, blackboard : Dictionary) -> int:
	var state := (get_child(0) as BTNode).tick(actor, blackboard)
	return do_decorate(state)

func do_decorate(state : int) -> int:
	match(decorate_style):
		Style.Succeeder:
			return STATE_SUCCESS
		Style.Inverter:
			match (state):
				STATE_RUNNING:
					return STATE_RUNNING
				STATE_FAILURE:
					return STATE_SUCCESS
				STATE_SUCCESS:
					return STATE_FAILURE
		Style.Limiter:
			if state == STATE_RUNNING:
				return state
			if counter > limit:
				return STATE_FAILURE
			counter += 1
			return STATE_SUCCESS
	return STATE_SUCCESS
