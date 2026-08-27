extends Node
class_name HealthComponent


signal died

@export var max_health: int

var current_damage: int


func setup() -> void:
	current_damage = max_health


func apply_damage(damage: int) -> void:
	current_damage = min(current_damage - damage, damage)
	if current_damage <= 0:
		died.emit()
