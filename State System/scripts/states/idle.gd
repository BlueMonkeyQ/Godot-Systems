class_name IdleState extends PlayerState

func enter() -> void:
	if not player:
		push_error( "Idle State: Player not found" )
		return
		
	player.velocity = Vector2.ZERO
	player.animation_controller.update_animation( "idle" )

func update(delta: float) -> void:
	var direction = Input.get_vector( "left", "right", "up", "down" )
	if direction != Vector2.ZERO:
		if Input.is_action_pressed( "run" ):
			state_machine.change_state( "run" )
		else:
			state_machine.change_state( "walk" )
		return
	return
