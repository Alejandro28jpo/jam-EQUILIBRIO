extends CanvasLayer
class_name PlayerInterface


@export var player: Player
@export var score_popup_scene: PackedScene = preload("res://ui/player_interface/score_popup.tscn")
@export var main_menu_scene: String = "uid://dgijqkbas0cdl"

@export var game_over_fall_start_offset: Vector2 = Vector2(0.0, -400.0)
@export var game_over_fall_duration: float = 0.6
@export var game_over_pulse_scale: float = 1.15
@export var game_over_pulse_duration: float = 0.25
@export var game_over_hold_duration: float = 1.0

@export var bullet_indicator_squish_scale: Vector2 = Vector2(1.35, 0.7)
@export var bullet_indicator_squish_duration: float = 0.08

@onready var temperature_meter: Sprite2D = $TemperatureMeter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hearts_display: HeartsDisplay = $Hearts
@onready var puntos_label: Label = $puntos
@onready var bullet_indicator: Label = $bulletIndicator
@onready var game_over_advise: Sprite2D = $GameOverAdvise

var current_state: GlobalEnums.EntityState
var state_to_show: int

var _game_over_rest_position: Vector2
var _bullet_indicator_tween: Tween


func _ready() -> void:
	_game_over_rest_position = game_over_advise.position
	game_over_advise.visible = false


func _process(delta: float) -> void:
	$puntos.text = "%s / %s" % [GameManager.current_score, GameManager.best_score]

func setup() -> void:
	current_state = player.temperature_component.state
	state_to_show = current_state#_state_to_frame(current_state)
	temperature_meter.frame = state_to_show
	player.temperature_component.state_changed.connect(_on_state_changed)
	hearts_display.setup(player.health_component.max_health)
	manage_health_label()
	GameManager.score_popup_requested.connect(_on_score_popup_requested)

	player.weapon_changed.connect(_on_weapon_changed)
	_on_weapon_changed(player.current_weapon)


func _on_score_popup_requested(points: int, world_position: Vector2) -> void:
	var screen_position: Vector2 = get_viewport().get_canvas_transform() * world_position

	var popup: ScorePopup = score_popup_scene.instantiate()
	popup.position = screen_position
	popup.target_global_position = puntos_label.global_position
	popup.setup(points)
	popup.collected.connect(_on_score_popup_collected)
	add_child(popup)


func _on_score_popup_collected(points: int) -> void:
	GameManager.add_score(points)


func show_game_over() -> void:
	GameManager.save_best_score()

	game_over_advise.visible = true
	game_over_advise.scale = Vector2.ONE
	game_over_advise.position = _game_over_rest_position + game_over_fall_start_offset

	var fall_tween: Tween = create_tween()
	fall_tween.tween_property(game_over_advise, "position", _game_over_rest_position, game_over_fall_duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await fall_tween.finished

	var pulse_tween: Tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(game_over_advise, "scale", Vector2.ONE * game_over_pulse_scale, game_over_pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(game_over_advise, "scale", Vector2.ONE, game_over_pulse_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await get_tree().create_timer(game_over_hold_duration).timeout
	pulse_tween.kill()

	Transition.change_scene(main_menu_scene)


func _on_weapon_changed(weapon: Player.Weapon) -> void:
	bullet_indicator.text = "WARM" if weapon == Player.Weapon.WARM else "COLD"
	_squish_bullet_indicator()


func _squish_bullet_indicator() -> void:
	bullet_indicator.pivot_offset = bullet_indicator.size / 2.0

	if _bullet_indicator_tween:
		_bullet_indicator_tween.kill()
	bullet_indicator.scale = Vector2.ONE

	_bullet_indicator_tween = create_tween()
	_bullet_indicator_tween.tween_property(bullet_indicator, "scale", bullet_indicator_squish_scale, bullet_indicator_squish_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_bullet_indicator_tween.tween_property(bullet_indicator, "scale", Vector2.ONE, bullet_indicator_squish_duration * 2.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func manage_health_label() -> void:
	hearts_display.set_current_damage(player.health_component.current_damage, player.health_component.max_health)


func update_temperature_meter() -> void:
	temperature_meter.frame = state_to_show

func _on_state_changed(new_state: GlobalEnums.EntityState, _old_state: GlobalEnums.EntityState) -> void:
	if new_state > current_state:
		current_state = new_state
		state_to_show = new_state # _state_to_frame(new_state)
		animation_player.play("TemperatureUP")
		await animation_player.animation_finished
		animation_player.play("IDLE")
	elif new_state < current_state:
		current_state = new_state
		state_to_show = new_state# _state_to_frame(new_state)
		animation_player.play("TemperatureDOWN")
		await animation_player.animation_finished
		animation_player.play("IDLE")


func _state_to_frame(state: int) -> int:
	return (GlobalEnums.EntityState.size() - 1) - state
