@tool
extends Node2D
class_name Room


enum RoomType {
	AllDoors,
	UpDoors, DownDoors, LeftDoors, RightDoors, 
	UpLeftDoors, UpRightDoors, MiddleDoors,
	UpDownDoors, DownLeftDoors, DownRightDoors,
	OnlyLeftDoor, OnlyRightDoor, OnlyUpDoor,
	OnlyDownDoor
}
const DOOR_FRAMES := {
	RoomType.AllDoors: 0,
	RoomType.UpDoors: 1,
	RoomType.DownDoors: 2,
	RoomType.LeftDoors: 3,
	RoomType.RightDoors: 4,
	RoomType.UpLeftDoors: 5,
	RoomType.UpRightDoors: 6,
	RoomType.MiddleDoors: 7,
	RoomType.UpDownDoors: 8,
	RoomType.DownLeftDoors: 9,
	RoomType.DownRightDoors: 10,
	RoomType.OnlyLeftDoor: 11,
	RoomType.OnlyRightDoor: 12,
	RoomType.OnlyUpDoor: 13,
	RoomType.OnlyDownDoor: 14
}
@onready var no_doors: Sprite2D = $NoDoors
@onready var all_rooms: Sprite2D = $AllRooms
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_forms: Node2D = $CollisionForms

@export var current_room_type: RoomType = RoomType.AllDoors:
	set(value):
		current_room_type = value
		_update_room_type()
@export var locked: bool = false


func _ready() -> void:
	_update_room_type()


func _update_room_type() -> void:
	if not is_node_ready():
		return
	all_rooms.frame = DOOR_FRAMES[current_room_type]
	var type_name = RoomType.keys()[current_room_type]
	for child in collision_forms.get_children():
		if child is StaticBody2D:
			var active = child.name == type_name
			child.visible = active
			for shape in child.get_children():
				if shape is CollisionShape2D:
					shape.disabled = not active


func _unlock_current_room_type() -> void:
	print("Cuarto desbloqueao")
