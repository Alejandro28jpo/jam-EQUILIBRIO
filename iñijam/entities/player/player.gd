extends CharacterBody2D
class_name Player


@onready var move_component: MoveComponent = $MoveComponent


func _physics_process(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_component.move(input_dir)
