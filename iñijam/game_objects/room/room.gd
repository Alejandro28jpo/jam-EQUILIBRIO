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

@export var current_room_type: RoomType
@export var locked: bool = false


func _unlock_current_room_type() -> void:
	print("Cuarto desbloqueao")
