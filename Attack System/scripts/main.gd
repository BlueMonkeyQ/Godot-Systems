class_name Player extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var state_machine = $"State Machine"
@onready var hurtbox = $Hurtbox
@onready var hurtbox_2d = $Hurtbox/CollisionShape2D

@onready var animation_controller = preload("res://Attack System/scripts/animations.gd").new()
@onready var attack_system = $"Attack System"

var current_direction : Vector2 = Vector2.DOWN
var attack_direction : Vector2 = Vector2.DOWN
var attack_angle : float = 0.0
var movement_speed : float = 100.00
var run_speed : float = 1.5

func _ready():
	attack_system.player = self
	animation_controller.player = self
	state_machine.start( "idle" )
	
func _physics_process(_delta):
	move_and_slide()

func update_direction( x: float, y : float ) -> Vector2:
	if y != 0:
		return Vector2(0, y).normalized()
	else:
		return Vector2(x, 0).normalized()
		
func update_attack_direction() -> Vector2:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var player_pos: Vector2 = global_position
	attack_angle = (mouse_pos - player_pos).angle()
	
	var dx = mouse_pos.x - player_pos.x
	var dy = mouse_pos.y - player_pos.y
	var attack_angle = atan2(dy, dx)
	
	if attack_angle < -PI * 3.0/4.0 or attack_angle > PI * 3.0/4.0:
		attack_direction = Vector2.LEFT
	elif attack_angle > -PI * 3.0/4.0 and attack_angle < -PI * 1.0/4.0:
		attack_direction = Vector2.UP
	elif attack_angle > -PI * 1.0/4.0 and attack_angle < PI * 1.0/4.0:
		attack_direction = Vector2.RIGHT
	else:
		attack_direction = Vector2.DOWN
		
	return attack_direction
