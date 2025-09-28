class_name IdleState extends PlayerState

func enter() -> void:
	if not player:
		push_error( "Idle State: Player not found" )
		return
		
	player.velocity = Vector2.ZERO
	player.animation_controller.update_animation( "idle" )

func update(_delta: float) -> void:
	if Input.is_action_pressed( "primary" ):
		state_machine.change_state( "attack" )
		return
		
	return
