class_name AttackState extends PlayerState

func enter() -> void:
	if not player:
		push_error( "Attack State: Player not found" )
		return
		
	if not player.attack_system:
		push_error( "Attack State: Attack System Not Found" )
		return
		
	# Listen for attack_executed signals. If connected, pass function to handle signal
	if not player.attack_system.attack_executed.is_connected( _on_attack_executed ):
		player.attack_system.attack_executed.connect( _on_attack_executed )
	
	player.hurtbox_2d.disabled = true
	player.velocity = Vector2.ZERO
	player.current_direction = player.update_attack_direction()
	player.attack_system.execute_attack( "primary" )

func update(_delta: float) -> void:
	pass
	
func exit() -> void:
	if player.attack_system.attack_executed.is_connected( _on_attack_executed ):
		player.attack_system.attack_executed.disconnect( _on_attack_executed )
		
	player.current_direction = player.attack_direction
	
func setup_attack_hurtbox( attack_data ) -> void:
	var attack_angle = player.attack_angle
	var hitbox_type = attack_data.get( "hitboxType", "slash" )
	
	match hitbox_type:
		"slash":
			setup_slash_hurtbox( attack_angle )
		"thrust":
			setup_thrust_hurtbox( attack_angle )

func setup_slash_hurtbox( attack_angle: float ) -> void:
	# Slash: width extends out from player
	var cos_angle : float = cos(attack_angle)
	var sin_angle : float = sin(attack_angle)
	
	var hitbox_width : float = 30.0
	var hitbox_height : float = 60.0
	
	var rect_shape = player.hurtbox_2d.shape as RectangleShape2D
	if rect_shape:
		rect_shape.size = Vector2(hitbox_width, hitbox_height)
	
	player.hurtbox_2d.rotation = attack_angle
	
	var center_x = cos_angle * (hitbox_width / 2)
	var center_y = sin_angle * (hitbox_width / 2)
	player.hurtbox.position = Vector2(center_x, center_y)

func setup_thrust_hurtbox( attack_angle: float ) -> void:
	# Thrust: length extends out from player
	var cos_angle : float = cos(attack_angle)
	var sin_angle : float = sin(attack_angle)
	
	var hitbox_width : float = 60.0
	var hitbox_height : float = 30.0
	
	var rect_shape = player.hurtbox_2d.shape as RectangleShape2D
	if rect_shape:
		rect_shape.size = Vector2(hitbox_width, hitbox_height)
	
	player.hurtbox_2d.rotation = attack_angle
	
	var center_x = cos_angle * (hitbox_width / 2)
	var center_y = sin_angle * (hitbox_width / 2)
	player.hurtbox.position = Vector2(center_x, center_y)

func _on_attack_executed( attack_data : Dictionary ):
	if attack_data.is_empty():
		push_warning( "Attack State: Attack Data is empty" )
		return
	
	var animation_name : String = attack_data.get( "animation", "idle" )
	player.animation_controller.update_animation( animation_name )
	if not player.animated_sprite_2d.animation_finished.is_connected( _on_attack_animation_finished ):
		player.animated_sprite_2d.animation_finished.connect( _on_attack_animation_finished )
	
	# Hurtbox
	setup_attack_hurtbox( attack_data )
	
	# Hurtbox
	player.hurtbox.monitoring = true
	player.hurtbox.visible = true
	
	# Hurtbox Collision 2D
	player.hurtbox_2d.disabled = false

func _on_attack_animation_finished() -> void:
	print( "Attack State: Attack Animation Finished" )
	player.hurtbox.monitoring = false
	player.hurtbox.visible = false
	player.hurtbox_2d.disabled = true
	player.attack_system.start_combo_window()
	state_machine.change_state( "idle" )
