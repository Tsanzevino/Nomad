class_name MovementStateMachine extends StateMachine

func _ready() -> void:
	for state_node : MovementState in find_children("*", "MovementState"):
		state_node.finished.connect(_transition_to_next_state)
		state_node.player = owner
	
	await owner.ready
	state.enter("")
