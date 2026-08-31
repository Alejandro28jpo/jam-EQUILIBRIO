extends CharacterBody2D
class_name Player


var murido = preload("res://sonidos/gameplay/MUERTE.ogg")
var canbiar_arma = preload("res://sonidos/gameplay/CAMBIAR_ARMA.ogg")
var distaro1 = preload("res://sonidos/gameplay/ARMA_FUEGO.ogg")
var recibir_daño = preload("res://sonidos/gameplay/RECIBIR_DAÑO.ogg")

enum Weapon { COLD, WARM }

@export var cold_bullet_scene: PackedScene = preload("res://entities/bullets/cold_bullet.tscn")
@export var warm_bullet_scene: PackedScene = preload("res://entities/bullets/warm_bullet.tscn")
@export var shoot_cooldown: float = 0.25
@export var shoot_self_temperature_effect: float = 5.0

@export var invulnerability_time: float = 0.3
@export var blink_interval: float = 0.05

@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent

@onready var player_interface: PlayerInterface = $PlayerInterface
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shoot_cooldown_timer: Timer = $ShootCooldownTimer
@onready var bullet_spawn_position: Marker2D = $BulletSpawnPosition

var dir: Vector2 = Vector2.ZERO
var current_weapon: Weapon = Weapon.COLD

var is_taking_damage: bool = false
var is_invulnerable: bool = false
var is_dead: bool = false


func _ready() -> void:
	health_component.setup()
	temperature_component.setup()
	player_interface.setup()
	health_component.died.connect(_on_died)
	temperature_component.died.connect(func(_cause: GlobalEnums.EntityState) -> void: _on_died())


func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if is_taking_damage:
		move_component.move(Vector2.ZERO)
		return

	dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_component.move(dir)
	_update_facing()

	if Input.is_action_just_pressed("switch_weapon"):
		ControladorAudio.reproducir_sonido(canbiar_arma)
		_switch_weapon()
	if Input.is_action_pressed("shoot") and shoot_cooldown_timer.is_stopped():
		ControladorAudio.reproducir_sonido(distaro1)
		_shoot()

	if is_dead:
		return

	_manage_animations()


func take_damage(damage: int) -> void:
	ControladorAudio.reproducir_sonido(recibir_daño)
	if is_dead or is_invulnerable:
		return

	health_component.apply_damage(damage)
	player_interface.manage_health_label()

	if is_dead:
		return

	is_invulnerable = true
	is_taking_damage = true
	velocity = Vector2.ZERO
	animation_player.play("DAMAGE")
	await animation_player.animation_finished

	if is_dead:
		return

	is_taking_damage = false
	await _blink()

	if is_dead:
		return
	is_invulnerable = false


func _on_died() -> void:
	ControladorAudio.reproducir_sonido(murido)
	if is_dead:
		return

	is_dead = true
	is_taking_damage = false
	is_invulnerable = true
	velocity = Vector2.ZERO
	sprite_2d.visible = true

	animation_player.play("DYING")
	await animation_player.animation_finished
	animation_player.play("DEAD")


func _blink() -> void:
	var elapsed: float = 0.0
	while elapsed < invulnerability_time:
		sprite_2d.visible = not sprite_2d.visible
		await get_tree().create_timer(blink_interval).timeout
		elapsed += blink_interval
	sprite_2d.visible = true


func _switch_weapon() -> void:
	current_weapon = Weapon.WARM if current_weapon == Weapon.COLD else Weapon.COLD


func _shoot() -> void:
	var bullet_scene: PackedScene = warm_bullet_scene if current_weapon == Weapon.WARM else cold_bullet_scene
	var bullet = bullet_scene.instantiate()
	var aim_direction: Vector2 = global_position.direction_to(get_global_mouse_position())

	get_tree().current_scene.add_child(bullet)
	bullet.launch(bullet_spawn_position.global_position, aim_direction)

	var self_effect: float = shoot_self_temperature_effect if current_weapon == Weapon.WARM else -shoot_self_temperature_effect
	temperature_component.affect_temperature(self_effect)

	shoot_cooldown_timer.start(shoot_cooldown)


func _update_facing() -> void:
	
	var facing_left: bool = get_global_mouse_position().x < global_position.x
	sprite_2d.flip_h = facing_left
	bullet_spawn_position.position.x = -13.0 if facing_left else 13.0


func _manage_animations() -> void:
	if dir:
		animation_player.play("WALK")
	else:
		animation_player.play("IDLE")
