extends Node2D
class_name HeartsDisplay


@export var heart_spacing: float = 28.0

@onready var _heart_template: Heart = $Heart

var _hearts: Array[Heart] = []


func setup(max_health: int) -> void:
	for heart in _hearts:
		if heart != _heart_template:
			heart.queue_free()
	_hearts.clear()

	_heart_template.position.x = 0.0
	_heart_template.is_alive = true
	_hearts.append(_heart_template)

	for i in range(1, max_health):
		var heart: Heart = _heart_template.duplicate()
		heart.position.x = i * heart_spacing
		add_child(heart)
		_hearts.append(heart)


func set_current_damage(current_damage: int, _max_health: int) -> void:
	for i in _hearts.size():
		if i >= current_damage:
			_hearts[i].lose()
		else:
			_hearts[i].revive()
