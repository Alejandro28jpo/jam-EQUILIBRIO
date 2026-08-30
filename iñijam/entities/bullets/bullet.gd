extends Area2D
class_name Bullet


@export var speed: float = 400.0
@export var damage: int = 0
@export var temperature_effect: float = 0.0
@export var lifetime: float = 1.5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction: Vector2 = Vector2.RIGHT
var _has_impacted: bool = false


func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


func _physics_process(delta: float) -> void:
	if _has_impacted:
		return
	position += direction * speed * delta


func launch(from_position: Vector2, to_direction: Vector2) -> void:
	global_position = from_position
	direction = to_direction.normalized()
	rotation = direction.angle()


func _on_lifetime_timeout() -> void:
	if not _has_impacted:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _has_impacted or body.is_in_group("player"):
		return

	if body is Enemy:
		if damage > 0 and body.has_node("HealthComponent"):
			body.get_node("HealthComponent").apply_damage(damage)
		if temperature_effect != 0.0 and body.has_node("TemperatureComponent"):
			body.get_node("TemperatureComponent").affect_temperature(temperature_effect)

	_impact()


func _impact() -> void:
	_has_impacted = true
	collision_shape.set_deferred("disabled", true)

	if animation_player.has_animation("FLY"):
		animation_player.play("FLY")
		await animation_player.animation_finished

	queue_free()
