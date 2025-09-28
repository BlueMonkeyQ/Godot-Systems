extends Node

var player : Player
var attack_data : Dictionary = {}
var combat_style : String = "melee"

var current_combo_sequence : Array = []
var combo_cooldown : float = 0.0
var combo_duration : float = 1.5
var is_combo_active : bool = false

signal attack_executed( attak_data ) # When call, signals this 'signal' with attack_data

func _ready():
	var file = FileAccess.open("res://Attack System/attacks.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			attack_data = json.data
			print( "Attacks loaded successfully" )
		else:
			print( "Error parsing attacks.json: ", json.get_error_message() )
	else:
		print( "Could not open attacks.json file" )
		
func _process(delta):
	if is_combo_active:
		combo_cooldown -= delta
		if combo_cooldown <= 0.0:
			reset_combo()

func execute_attack( input_sequence:String ) -> void:
	current_combo_sequence.append( input_sequence )
	var attack = find_matching_attack()
	if attack.is_empty():
		print( "No attack found, combo sequence: ", current_combo_sequence )
		reset_combo()
	else:
		print( "Attack: ", attack )
		attack_executed.emit( attack )
		if attack.get( "endCombo", false):
			reset_combo()
	return

func find_matching_attack() -> Dictionary:
	# First priority: Check for attacks with secondary keys
	for attack in attack_data[combat_style]:
		if attack["sequence"].size() == current_combo_sequence.size():
			var sequence_matches = true
			for i in range(attack["sequence"].size()):
				if attack["sequence"][i] != current_combo_sequence[i]:
					sequence_matches = false
					break
			
			if sequence_matches and attack.has("secondaryKey") and attack["secondaryKey"] != null:
				var secondary_key = attack["secondaryKey"]
				if Input.is_action_pressed(secondary_key):
					return attack
	
	# Second priority: Check for regular sequence-only attacks
	for attack in attack_data[combat_style]:
		if attack["sequence"].size() == current_combo_sequence.size():
			var sequence_matches = true
			for i in range(attack["sequence"].size()):
				if attack["sequence"][i] != current_combo_sequence[i]:
					sequence_matches = false
					break
			
			if sequence_matches and (not attack.has("secondaryKey") or attack["secondaryKey"] == null):
				return attack
	
	return {}
	
func start_combo_window() -> void:
	is_combo_active = true
	combo_cooldown = combo_duration
	print( "Combo Window Active for ", combo_cooldown, " seconds")

func reset_combo() -> void:
	is_combo_active = false
	current_combo_sequence.clear()
	print( "Combo Reset" )
