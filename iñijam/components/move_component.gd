extends Node
class_name MoveComponent

@export var speed: float = 200.0

@onready var body: CharacterBody2D = get_parent()


func move(direction: Vector2) -> void:
	body.velocity = direction * speed
	body.move_and_slide()
