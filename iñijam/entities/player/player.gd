extends CharacterBody2D
class_name Player


@onready var health_component: HealthComponent = $HealthComponent
@onready var move_component: MoveComponent = $MoveComponent
@onready var temperature_component: TemperatureComponent = $TemperatureComponent

@onready var player_interface: PlayerInterface = $PlayerInterface


func _ready() -> void:
	health_component.setup()
	player_interface.setup()


func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_component.move(input_dir)
