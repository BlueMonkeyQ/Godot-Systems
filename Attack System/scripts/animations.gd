extends Node

var player : Player

func _ready():
	pass
	
func get_direction() -> String:
	if not player:
		push_error("Player not found")
		return ""
	
	if player.current_direction == Vector2.DOWN:
		return "down"
	elif player.current_direction == Vector2.UP:
		return "up"
	elif player.current_direction == Vector2.LEFT:
		return "left"
	elif player.current_direction == Vector2.RIGHT:
		return "right"
		
	return "down"

func update_animation( animation: String ) -> void:
	if not player:
		push_error("Player not found")
		return

	if not player.animated_sprite_2d:
		push_error("AnimatedSprite2D not found")
		return
		
	var direction : String = get_direction()
	player.animated_sprite_2d.play( animation + "-" + direction )
