extends Sprite2D
class_name Heart


const ALIVE_FRAMES: Array[int] = [0, 1, 2]
const LOST_FRAMES: Array[int] = [3, 4]

@export var frame_duration: float = 0.2
@export var fall_distance: float = 40.0
@export var fall_duration: float = 0.4

var is_alive: bool = true

var _frame_index: int = 0
var _elapsed: float = 0.0
var _is_falling: bool = false


func _ready() -> void:
	frame = ALIVE_FRAMES[0]


func _process(delta: float) -> void:
	if _is_falling:
		return
	_elapsed += delta
	if _elapsed >= frame_duration:
		_elapsed -= frame_duration
		_advance_frame()


func _advance_frame() -> void:
	var frames: Array[int] = ALIVE_FRAMES if is_alive else LOST_FRAMES
	_frame_index = (_frame_index + 1) % frames.size()
	frame = frames[_frame_index]


func lose() -> void:
	if not is_alive:
		return
	is_alive = false
	_is_falling = true

	var fall_tween: Tween = create_tween().set_parallel(true)
	fall_tween.tween_property(self, "position:y", position.y + fall_distance, fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_tween.tween_property(self, "modulate:a", 0.0, fall_duration)
	await fall_tween.finished

	position.y -= fall_distance
	modulate.a = 1.0
	_frame_index = 0
	_elapsed = 0.0
	frame = LOST_FRAMES[0]
	_is_falling = false
