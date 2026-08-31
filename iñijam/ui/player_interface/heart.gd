extends Node2D
class_name Heart


const ALIVE_FRAMES: Array[int] = [0, 1, 2]
const LOST_FRAMES: Array[int] = [3, 4]

@export var frame_duration: float = 0.2
@export var fall_distance: float = 40.0
@export var fall_duration: float = 0.4

@onready var _alive: Sprite2D = $Alive
@onready var _empty: Sprite2D = $Empty

var is_alive: bool = true

var _frame_index: int = 0
var _empty_frame_index: int = 0
var _elapsed: float = 0.0


func _ready() -> void:
	_alive.frame = ALIVE_FRAMES[0]


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < frame_duration:
		return
	_elapsed -= frame_duration

	if is_alive:
		_frame_index = (_frame_index + 1) % ALIVE_FRAMES.size()
		_alive.frame = ALIVE_FRAMES[_frame_index]
	elif _empty.visible:
		_empty_frame_index = (_empty_frame_index + 1) % LOST_FRAMES.size()
		_empty.frame = LOST_FRAMES[_empty_frame_index]


func lose() -> void:
	if not is_alive:
		return
	is_alive = false

	_empty.frame = LOST_FRAMES[0]
	_empty.visible = true

	var fall_tween: Tween = create_tween()
	fall_tween.set_parallel(true)
	fall_tween.tween_property(_alive, "position:y", _alive.position.y + fall_distance, fall_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_tween.tween_property(_alive, "modulate:a", 0.0, fall_duration)
	fall_tween.chain().tween_callback(func() -> void: _alive.visible = false)
