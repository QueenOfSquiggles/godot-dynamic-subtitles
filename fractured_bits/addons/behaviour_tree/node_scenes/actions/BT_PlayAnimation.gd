extends BTLeaf

export (NodePath) var animator_node : NodePath
export (String) var animation_name := ""
export (bool) var override_current_animation := false
export (bool) var hold_until_complete := true

onready var animator := get_node(animator_node) as AnimationPlayer

enum AnimState {
	UNSET, COMPLETED, RUNNING
}
var anim_state = AnimState.UNSET

func tick(actor : Node, blackboard : Dictionary) -> int:
	if anim_state == AnimState.COMPLETED:
		anim_state = AnimState.UNSET
		return STATE_SUCCESS

	if anim_state == AnimState.RUNNING:
		return STATE_RUNNING

	if animator.is_playing():
		if not override_current_animation:
			return STATE_RUNNING
	animator.play(animation_name)
	if hold_until_complete:
		# if we are holding until complete, assign the lock and connect to the completion signal
		anim_state = AnimState.RUNNING
		animator.connect("animation_finished", self, "on_anim_complete", [], CONNECT_ONESHOT)
		return STATE_RUNNING
	return STATE_SUCCESS

func on_anim_complete(name : String) -> void:
	if name != animation_name:
		# if this keeps coming up and no clear problems persist, feel free to remove this assertion
		assert(false, "This should literally never get triggered.")
		return
	anim_state = AnimState.COMPLETED
