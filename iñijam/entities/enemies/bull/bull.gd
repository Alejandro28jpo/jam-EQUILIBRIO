extends Enemy
class_name Bull


enum State { CHASE, WINDUP, COOLDOWN }



@export var attack_range: float = 40.0
@export var windup_time: float = 0.5
@export var attack_cooldown: float = 1.0
@export var attack_damage: int = 1

@export var contact_damage: int = 1
@export var contact_damage_cooldown: float = 0.6

@onready var attack_area: Area2D = $AttackArea
@onready var contact_area: Area2D = $ContactArea
@onready var contact_cooldown_timer: Timer = $ContactCooldownTimer

var state: State = State.CHASE
var _state_timer: float = 0.0


func _ready() -> void:
	super._ready()
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	contact_area.body_entered.connect(_on_contact_area_body_entered)
	contact_cooldown_timer.timeout.connect(_on_contact_cooldown_timeout)


func get_speed_multiplier() -> float:
	var temp_state: GlobalEnums.EntityState = temperature_component.state
	if temp_state == GlobalEnums.EntityState.FREEZING or temp_state == GlobalEnums.EntityState.PEAK_FREEZE:
		return 0.0
	return super.get_speed_multiplier()


func _update_ai(delta: float) -> void:
	if get_speed_multiplier() <= 0.0:
		move_component.move(Vector2.ZERO)
		_play_animation("FREEZED")
		return

	match state:
		State.CHASE:
			_chase()
		State.WINDUP:
			_windup(delta)
		State.COOLDOWN:
			_cooldown(delta)


func _chase() -> void:
	if distance_to_player() <= attack_range:
		_enter_windup()
		return

	move_component.move(direction_to_player() * get_speed_multiplier())
	_play_animation("WALK")


func _enter_windup() -> void:
	state = State.WINDUP
	_state_timer = windup_time
	move_component.move(Vector2.ZERO)
	_play_animation("IDLE")


func _windup(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_smash()


func _smash() -> void:
	_play_animation("SMASH")
	state = State.COOLDOWN
	_state_timer = attack_cooldown


func _cooldown(delta: float) -> void:
	move_component.move(Vector2.ZERO)
	_state_timer -= delta
	if _state_timer <= 0.0:
		state = State.CHASE


func _on_attack_area_body_entered(body: Node) -> void:
	_damage_player(body, attack_damage)


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


func _update_facing() -> void:
	if player == null:
		return
	sprite_2d.flip_h = player.global_position.x > global_position.x


func _play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
