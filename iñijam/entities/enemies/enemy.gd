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
@export var freeze_tremble_amplitude: float = 1.5
@export var freeze_tremble_speed: float = 0.06

@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent
@onready var score_component: ScoreComponent = $ScoreComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var player: Node2D
var is_dead: bool = false
var is_spawning: bool = true
var is_frozen: bool = false
var is_thawing: bool = false

var _sprite_base_position: Vector2
var _tremble_tween: Tween


func _ready() -> void:
	_sprite_base_position = sprite_2d.position
	health_component.setup()
	temperature_component.setup()
	score_component.setup()
	health_component.died.connect(_die)
	health_component.damage_taken.connect(_on_damage_taken)
	temperature_component.died.connect(_die_from_temperature)
	temperature_component.frozen_changed.connect(_on_frozen_changed)
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
			var is_attack_hitbox: bool = node.get_parent() is Area2D and node.get_parent().name == "AttackArea"
			node.set_deferred("disabled", not enabled or is_attack_hitbox)
		elif node is Area2D:
			node.set_deferred("monitoring", enabled)
			node.set_deferred("monitorable", enabled)


func _collect_descendants(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_collect_descendants(child))
	return result


func _update_ai(_delta: float) -> void:
	pass


func _on_damage_taken(_amount: int) -> void:
	pass


func _update_facing() -> void:
	if velocity.x != 0.0:
		sprite_2d.flip_h = velocity.x < 0.0


func get_speed_multiplier() -> float:
	return SPEED_MULTIPLIERS.get(temperature_component.state, 1.0)


func is_immobilized() -> bool:
	return is_frozen or is_thawing


func _on_frozen_changed(frozen: bool) -> void:
	if is_dead:
		return
	if frozen:
		is_frozen = true
		_play_freeze_in()
	else:
		is_frozen = false
		_play_freeze_out()


func _play_freeze_in() -> void:
	_stop_tremble()
	if animation_player.has_animation("FREEZED"):
		animation_player.play("FREEZED")
		await animation_player.animation_finished
	if is_frozen:
		_start_tremble()


func _play_freeze_out() -> void:
	_stop_tremble()
	is_thawing = true
	if animation_player.has_animation("FREEZED"):
		animation_player.play_backwards("FREEZED")
		await animation_player.animation_finished
	is_thawing = false


func _start_tremble() -> void:
	_tremble_tween = create_tween().set_loops()
	_tremble_tween.tween_property(sprite_2d, "position", _sprite_base_position + Vector2(freeze_tremble_amplitude, 0.0), freeze_tremble_speed)
	_tremble_tween.tween_property(sprite_2d, "position", _sprite_base_position - Vector2(freeze_tremble_amplitude, 0.0), freeze_tremble_speed)
	_tremble_tween.tween_property(sprite_2d, "position", _sprite_base_position, freeze_tremble_speed)


func _stop_tremble() -> void:
	if _tremble_tween:
		_tremble_tween.kill()
		_tremble_tween = null
	sprite_2d.position = _sprite_base_position


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
	_stop_tremble()
	_set_collisions_enabled(false)
	died.emit()
	queue_free()


func _die_from_temperature(_cause: GlobalEnums.EntityState) -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	move_component.move(Vector2.ZERO)
	_stop_tremble()

	_set_collisions_enabled(false)

	if animation_player.has_animation("BURNED"):
		animation_player.play("BURNED")
		var anim_length: float = animation_player.get_animation("BURNED").length
		await get_tree().create_timer(anim_length).timeout

	died.emit()
	queue_free()
