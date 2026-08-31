extends Area2D
class_name RoomExit


@export var heal_amount: int = 1
@export var walk_duration: float = 0.4

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_exit_point: Marker2D = $PlayerExitPoint

var player: Player
var main_level: MainLevel

var _is_triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _is_triggered or not body.is_in_group("player"):
		return
	_is_triggered = true
	set_deferred("monitoring", false)
	_trigger_exit()


func _trigger_exit() -> void:
	player.is_exiting = true
	player.velocity = Vector2.ZERO
	player.sprite_2d.flip_h = player_exit_point.global_position.x < player.global_position.x
	player.animation_player.play("WALK")

	var move_tween: Tween = create_tween()
	move_tween.tween_property(player, "global_position", player_exit_point.global_position, walk_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await move_tween.finished

	player.animation_player.play("IDLE")
	animation_player.play("OPENING")
	await animation_player.animation_finished

	player.visible = false

	animation_player.play_backwards("OPENING")
	await animation_player.animation_finished

	player.health_component.heal(heal_amount)
	player.player_interface.manage_health_label()

	var next_level: int = GameManager.current_level + 1
	await Transition.fade_in(true, next_level)

	# main_level.next_level() regenerates the rooms, which frees this very
	# node (it belongs to the room being cleared) — nothing below this point
	# may depend on `self` still being alive, so fade_out is fire-and-forget.
	main_level.next_level()
	player.visible = true
	player.is_exiting = false
	Transition.fade_out(true, next_level)
