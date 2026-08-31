extends Node2D

func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	$AnimationPlayer.play("comienzo")
	await get_tree().create_timer(2.9).timeout
	$UQ2Hb2391VbThunderClap521194.play()
	$ExplosionBlastFireHeavyCrackle01.play()
	$AmbienceNatureTrail18001.stop()
	await get_tree().create_timer(3.5).timeout
	$UniversfieldManPainScream567203.play()
	await get_tree().create_timer(2.5).timeout
	$UQ2Hb2391VbThunderClap521194.stop()
	$ExplosionBlastFireHeavyCrackle01.stop()
	await get_tree().create_timer(0.8).timeout
	$BryansantosbretonDarknessTonalCymbalRollRiserBraamImpact184275.play()
	

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
