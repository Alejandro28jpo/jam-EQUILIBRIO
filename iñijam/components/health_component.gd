extends Node
class_name HealthComponent


signal died
signal damage_taken(amount: int)

@export var max_health: int

var current_damage: int


func setup() -> void:
	current_damage = max_health


func apply_damage(damage: int) -> void:
	current_damage = max(current_damage - damage, 0)
	damage_taken.emit(damage)

	if current_damage <= 0:
		died.emit()
