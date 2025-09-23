class_name PlayerStateMachine extends Node

var current_state: PlayerState
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = get_parent() as Player

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func _input(event):
	if current_state:
		current_state.handle_input(event)

func change_state(state_name: String):
	var new_state = states.get(state_name.to_lower())
	if new_state == current_state or not new_state:
		return
	
	if current_state:
		current_state.exit()
	
	print( "Entering State: " + state_name )
	current_state = new_state
	current_state.enter()

func start(initial_state: String):
	current_state = states.get(initial_state.to_lower())
	if current_state:
		print( "Entering State: " + initial_state )
		current_state.enter()
