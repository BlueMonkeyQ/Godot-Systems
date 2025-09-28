class_name PlayerState extends Node

static var player: Player
var state_machine: PlayerStateMachine

func _ready():
	# Get references when the state is added to the scene
	pass

func enter():
	# Called when entering this state
	pass

func exit():
	# Called when leaving this state
	pass

# Called every frame while in this state
func update(_delta: float):
	pass

func physics_update(_delta: float):
	# Called every physics frame while in this state
	pass

func handle_input(_event: InputEvent):
	# Handle input events
	pass
