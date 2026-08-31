extends CanvasLayer
class_name PlayerInterface


@export var player: Player
@export var score_popup_scene: PackedScene = preload("res://ui/player_interface/score_popup.tscn")

@onready var temperature_meter: Sprite2D = $TemperatureMeter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hearts_display: HeartsDisplay = $Hearts
@onready var puntos_label: Label = $puntos

var current_state: GlobalEnums.EntityState
var state_to_show: int


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
