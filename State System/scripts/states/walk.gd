class_name WalkState extends PlayerState

func enter() -> void:
	if not player:
		push_error( " Walk State: Player not found" )
		return

func update(delta: float) -> void:
	var direction = Input.get_vector( "left", "right", "up", "down" )
	
	# Idle State
	if direction == Vector2.ZERO:
		state_machine.change_state( "idle" )
		return
	
	# Walk State
	if Input.is_action_pressed( "run" ):
		state_machine.change_state( "run" )
		return
	
	player.current_direction = player.update_direction( direction.x, direction.y )
	player.velocity = direction.normalized() * player.movement_speed
	player.animation_controller.update_animation( "walk" )
