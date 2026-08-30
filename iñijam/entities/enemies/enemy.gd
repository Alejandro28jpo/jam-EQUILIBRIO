extends CharacterBody2D
class_name Enemy


signal died

const SPEED_MULTIPLIERS := {
	GlobalEnums.EntityState.PEAK_FREEZE: 0.15,
	GlobalEnums.EntityState.FREEZING: 0.35,
	GlobalEnums.EntityState.DEEP_COLD: 0.6,
	GlobalEnums.EntityState.COLD: 0.85,
}

@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var player: Node2D
var is_dead: bool = false


func _ready() -> void:
	health_component.setup()
	temperature_component.setup()
	health_component.died.connect(_die)
	temperature_component.died.connect(func(_cause: GlobalEnums.EntityState) -> void: _die())
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	_update_ai(delta)
	_update_facing()


func _update_ai(_delta: float) -> void:
	pass


func _update_facing() -> void:
	if velocity.x != 0.0:
		sprite_2d.flip_h = velocity.x < 0.0


func get_speed_multiplier() -> float:
	return SPEED_MULTIPLIERS.get(temperature_component.state, 1.0)


func direction_to_player() -> Vector2:
	if player == null:
		return Vector2.ZERO
	return global_position.direction_to(player.global_position)


func distance_to_player() -> float:
	if player == null:
		return INF
	return global_position.distance_to(player.global_position)


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()
	queue_free()
