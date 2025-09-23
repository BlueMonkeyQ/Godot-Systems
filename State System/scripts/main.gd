class_name Player extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var state_machine = $"State Machine"
@onready var animation_controller = preload("res://State System/scripts/animations.gd").new()

var current_direction : Vector2 = Vector2.DOWN
var movement_speed : float = 100.00
var run_speed : float = 1.5

func _ready():
	animation_controller.player = self
	state_machine.start( "idle" )
	
func _physics_process(_delta):
	move_and_slide()

func update_direction( x: float, y : float ) -> Vector2:
	if y != 0:
		return Vector2(0, y).normalized()
	else:
		return Vector2(x, 0).normalized()
