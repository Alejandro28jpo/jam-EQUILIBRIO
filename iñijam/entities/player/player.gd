extends CharacterBody2D
class_name Player


@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent

@onready var player_interface: PlayerInterface = $PlayerInterface
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var dir: Vector2 = Vector2.ZERO


func _ready() -> void:
	health_component.setup()
	temperature_component.setup()
	player_interface.setup()


func _physics_process(_delta: float) -> void:
	dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_component.move(dir)
	
	_manage_animations()


func _manage_animations() -> void:
	if dir:
		animation_player.play("WALK")
		sprite_2d.flip_h = dir.x < 0
	else:
		animation_player.play("IDLE")
