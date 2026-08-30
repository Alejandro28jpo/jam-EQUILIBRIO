extends Node
class_name RoomManager

const ROOM_SIZE := Vector2(640, 320)

const UP := Vector2i(0, -1)
const DOWN := Vector2i(0, 1)
const LEFT := Vector2i(-1, 0)
const RIGHT := Vector2i(1, 0)

const DIR_BITS := {
	UP: 1,
	DOWN: 2,
	LEFT: 4,
	RIGHT: 8,
}

const DOOR_MASK_TO_ROOM_TYPE := {
	1: Room.RoomType.OnlyUpDoor,
	2: Room.RoomType.OnlyDownDoor,
	4: Room.RoomType.OnlyLeftDoor,
	8: Room.RoomType.OnlyRightDoor,
	3: Room.RoomType.UpDownDoors,
	5: Room.RoomType.UpLeftDoors,
	9: Room.RoomType.UpRightDoors,
	6: Room.RoomType.DownLeftDoors,
	10: Room.RoomType.DownRightDoors,
	12: Room.RoomType.MiddleDoors,
	13: Room.RoomType.UpDoors,
	14: Room.RoomType.DownDoors,
	7: Room.RoomType.LeftDoors,
	11: Room.RoomType.RightDoors,
	15: Room.RoomType.AllDoors,
}

@export var room_scene: PackedScene = preload("res://game_objects/room/room.tscn")

var rooms_by_cell: Dictionary = {}
var start_cell: Vector2i = Vector2i.ZERO


func generate(parent: Node, room_count: int) -> Vector2:
	_clear()

	var cells: Array[Vector2i] = [start_cell]
	var attempts := 0
	var max_attempts := maxi(room_count, 1) * 50

	while cells.size() < room_count and attempts < max_attempts:
		attempts += 1
		var from_cell: Vector2i = cells.pick_random()
		var directions := DIR_BITS.keys()
		directions.shuffle()
		for dir in directions:
			var next_cell: Vector2i = from_cell + dir
			if not cells.has(next_cell):
				cells.append(next_cell)
				break

	for cell in cells:
		var mask := 0
		for dir in DIR_BITS:
			if cells.has(cell + dir):
				mask |= DIR_BITS[dir]
		if mask == 0:
			mask = 15

		var room: Room = room_scene.instantiate()
		room.current_room_type = DOOR_MASK_TO_ROOM_TYPE[mask]
		room.position = Vector2(cell) * ROOM_SIZE
		parent.add_child(room)
		rooms_by_cell[cell] = room

	return Vector2(start_cell) * ROOM_SIZE


func cell_at(world_position: Vector2) -> Vector2i:
	return Vector2i(round(world_position.x / ROOM_SIZE.x), round(world_position.y / ROOM_SIZE.y))


func has_room(cell: Vector2i) -> bool:
	return rooms_by_cell.has(cell)


func room_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * ROOM_SIZE


func _clear() -> void:
	for room in rooms_by_cell.values():
		room.queue_free()
	rooms_by_cell.clear()
