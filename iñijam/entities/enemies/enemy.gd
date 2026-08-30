extends CharacterBody2D
class_name Enemy


signal died

const SPEED_MULTIPLIERS := {
	GlobalEnums.EntityState.PEAK_FREEZE: 0.15,
	GlobalEnums.EntityState.FREEZING: 0.35,
	GlobalEnums.EntityState.DEEP_COLD: 0.6,
	GlobalEnums.EntityState.COLD: 0.85,
}

@export var spawn_scale_duration: float = 0.5

@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var player: Node2D
var is_dead: bool = false
var is_spawning: bool = true


func _ready() -> void:
	health_component.setup()
	temperature_component.setup()
	health_component.died.connect(_die)
	temperature_component.died.connect(_die_from_temperature)
	player = get_tree().get_first_node_in_group("player")
	_play_spawn_animation()


func _physics_process(delta: float) -> void:
	if is_dead or is_spawning:
		return
	_update_ai(delta)
	_update_facing()


func _play_spawn_animation() -> void:
	is_spawning = true
	scale = Vector2.ZERO
	_set_collisions_enabled(false)
	if animation_player.has_animation("IDLE"):
		animation_player.play("IDLE")

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, spawn_scale_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

	if is_dead:
		return

	_set_collisions_enabled(true)
	is_spawning = false


func _set_collisions_enabled(enabled: bool) -> void:
	for node in _collect_descendants(self):
		if node is CollisionShape2D or node is CollisionPolygon2D:
			node.set_deferred("disabled", not enabled)
		elif node is Area2D:
			node.monitoring = enabled
			node.monitorable = enabled


func _collect_descendants(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_collect_descendants(child))
	return result


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
	_set_collisions_enabled(false)
	died.emit()
	queue_free()


func _die_from_temperature(cause: GlobalEnums.EntityState) -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	move_component.move(Vector2.ZERO)

	_set_collisions_enabled(false)

	var death_animation: String = "BURNED" if cause == GlobalEnums.EntityState.PEAK_BURN else "FREEZED"
	if animation_player.has_animation(death_animation):
		animation_player.play(death_animation)
		var anim_length: float = animation_player.get_animation(death_animation).length
		await get_tree().create_timer(anim_length).timeout

	died.emit()
	queue_free()
