extends Enemy
class_name Grouch


const DIRECTIONS: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

@export var contact_damage: int = 1
@export var contact_damage_cooldown: float = 0.6

@onready var contact_area: Area2D = $ContactArea
@onready var contact_cooldown_timer: Timer = $ContactCooldownTimer

var _direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	super._ready()
	contact_area.body_entered.connect(_on_contact_area_body_entered)
	contact_cooldown_timer.timeout.connect(_on_contact_cooldown_timeout)
	_direction = DIRECTIONS.pick_random()


func _update_ai(_delta: float) -> void:
	move_component.move(_direction * get_speed_multiplier())
	_play_animation("WALK")


func _on_contact_area_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if contact_cooldown_timer.is_stopped():
		_damage_player(body, contact_damage)
		contact_cooldown_timer.start(contact_damage_cooldown)


func _on_contact_cooldown_timeout() -> void:
	for body in contact_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_damage_player(body, contact_damage)
			contact_cooldown_timer.start(contact_damage_cooldown)
			return


func _damage_player(body: Node, damage: int) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)


func _play_animation(anim_name: String) -> void:
	if animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
