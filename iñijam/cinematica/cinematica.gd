extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _can_skip: bool = false
var _finished: bool = false


func _ready() -> void:
	_can_skip = GameManager.intro_seen


func _unhandled_input(event: InputEvent) -> void:
	if _can_skip and event.is_action_pressed("shoot"):
		_skip()


func _skip() -> void:
	if _finished:
		return
	animation_player.stop()
	_inicio()


func _inicio() -> void:
	if _finished:
		return
	_finished = true
	GameManager.mark_intro_seen()
	Transition.change_scene("uid://b4t2us54hecpu")
