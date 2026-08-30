extends CanvasLayer
class_name PlayerInterface


@export var player: Player

@onready var player_life: Label = $PlayerLife
@onready var temperature_meter: Sprite2D = $TemperatureMeter
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_state: GlobalEnums.EntityState
var state_to_show: int


func setup() -> void:
	current_state = player.temperature_component.state
	state_to_show = current_state#_state_to_frame(current_state)
	temperature_meter.frame = state_to_show
	player.temperature_component.state_changed.connect(_on_state_changed)
	manage_health_label()


func manage_health_label() -> void:
	player_life.text = "%s / %s" % [player.health_component.current_damage, player.health_component.max_health]


func update_temperature_meter() -> void:
	temperature_meter.frame = state_to_show

func _on_state_changed(new_state: GlobalEnums.EntityState, _old_state: GlobalEnums.EntityState) -> void:
	if new_state > current_state:
		current_state = new_state
		state_to_show = new_state # _state_to_frame(new_state)
		animation_player.play("TemperatureUP")
	elif new_state < current_state:
		current_state = new_state
		state_to_show = new_state# _state_to_frame(new_state)
		animation_player.play("TemperatureDOWN")


func _state_to_frame(state: int) -> int:
	return (GlobalEnums.EntityState.size() - 1) - state
