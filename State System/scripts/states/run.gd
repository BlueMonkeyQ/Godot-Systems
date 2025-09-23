class_name RunState extends PlayerState

func enter() -> void:
	if not player:
		push_error( "Run State: Player not found" )
		return

func update(delta: float) -> void:
	var direction = Input.get_vector( "left", "right", "up", "down" )
	
	# Idle State
	if direction == Vector2.ZERO:
		state_machine.change_state( "idle" )
		return
	
	# Walk State
	if not Input.is_action_pressed( "run" ):
		state_machine.change_state( "walk" )
		return
	
	player.current_direction = player.update_direction( direction.x, direction.y )
	
	var run_speed = player.movement_speed + ( player.movement_speed * player.run_speed )
	player.velocity = direction.normalized() * run_speed
	player.animation_controller.update_animation( "run" )
