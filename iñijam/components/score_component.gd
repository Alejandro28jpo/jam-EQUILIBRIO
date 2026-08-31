extends Node
class_name ScoreComponent


@export var points: int = 0

@onready var _enemy: Enemy = get_parent()


func setup() -> void:
	_enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	if points > 0:
		GameManager.score_popup_requested.emit(points, _enemy.global_position)
