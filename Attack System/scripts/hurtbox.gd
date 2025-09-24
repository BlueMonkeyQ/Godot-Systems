class_name Hurtbox extends Area2D

@export var damage_data : Dictionary = {}

func _ready():
	area_entered.connect( OnCollision )

func OnCollision( _area: Area2D ) -> void:
	pass
