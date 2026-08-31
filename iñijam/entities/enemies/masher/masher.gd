extends Bull
class_name Masher


@export var tired_duration: float = 1.0
@export var tired_modulate: Color = Color(0.6, 0.6, 0.6)

var _is_tired: bool = false


func is_immobilized() -> bool:
	return _is_tired or super.is_immobilized()


func _cooldown(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_go_tired()
	else:
		move_component.move(Vector2.ZERO)


func _go_tired() -> void:
	if _is_tired:
		return
	_is_tired = true
	modulate = tired_modulate
	await get_tree().create_timer(tired_duration).timeout
	_is_tired = false
	modulate = Color.WHITE
	state = State.CHASE
