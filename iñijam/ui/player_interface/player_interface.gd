extends CanvasLayer
class_name PlayerInterface


@export var player: Player

@onready var player_life: Label = $PlayerLife
@onready var player_state: Label = $PlayerState


func setup() -> void:
	manage_health_label()
	manage_state_label()


func manage_health_label() -> void:
	player_life.text = "%s / %s" % [player.health_component.current_damage, player.health_component.max_health]


func manage_state_label() -> void: player_state.text = GlobalEnums.EntityState.keys()[player.temperature_component.state]
