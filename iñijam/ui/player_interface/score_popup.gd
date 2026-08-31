extends Label
class_name ScorePopup

signal collected(points: int)

@export var scatter_radius: float = 50.0
@export var toss_height: float = 40.0
@export var toss_duration: float = 0.5
@export var rest_duration: float = 0.3
@export var travel_duration: float = 0.5

var target_global_position: Vector2

var _points: int = 0

func setup(points: int) -> void:
	_points = points
	text = "+%d" % points


func _ready() -> void:
	_play_sequence()
	ControladorAudio.reproducir_sonido(preload("res://sonidos/escenas/CINEMÁTICA/cinemática.ogg"))
	ControladorAudio.reproducir_musica(preload("res://sonidos/escenas/CINEMÁTICA/cinemática.ogg"))

func _play_sequence() -> void:
	var start_position: Vector2 = position
	var angle: float = randf_range(0.0, TAU)
	var distance: float = randf_range(scatter_radius * 0.4, scatter_radius)
	var land_position: Vector2 = start_position + Vector2(cos(angle), sin(angle)) * distance
	var peak_position: Vector2 = start_position.lerp(land_position, 0.5) - Vector2(0.0, toss_height)

	var toss_tween: Tween = create_tween()
	toss_tween.tween_property(self, "position", peak_position, toss_duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	toss_tween.tween_property(self, "position", land_position, toss_duration * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await toss_tween.finished

	await get_tree().create_timer(rest_duration).timeout

	var travel_tween: Tween = create_tween()
	travel_tween.tween_property(self, "global_position", target_global_position, travel_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await travel_tween.finished

	collected.emit(_points)
	queue_free()
