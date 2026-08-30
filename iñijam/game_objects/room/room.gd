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

signal cleared

@onready var no_doors: Sprite2D = $NoDoors
@onready var all_rooms: Sprite2D = $AllRooms
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_forms: Node2D = $CollisionForms
@onready var lock_trigger: Area2D = $LockTrigger

@export var current_room_type: RoomType = RoomType.AllDoors:
	set(value):
		current_room_type = value
		_update_room_type()
@export var locked: bool = false

@export var spawn_area_size: Vector2 = Vector2(420.0, 180.0)
@export var spawn_area_offset: Vector2 = Vector2(0.0, 10.0)

var has_encounter: bool = false

var _encounter_triggered: bool = false
var _enemy_scenes: Array[PackedScene] = []
var _enemies_alive: int = 0


func _ready() -> void:
	_update_room_type()
	if not Engine.is_editor_hint():
		lock_trigger.body_entered.connect(_on_lock_trigger_body_entered)


func setup_encounter(enemy_scenes: Array[PackedScene], enemy_count: int) -> void:
	if enemy_scenes.is_empty() or enemy_count <= 0:
		return
	has_encounter = true
	_enemy_scenes = enemy_scenes
	_enemies_alive = enemy_count


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
					shape.set_deferred("disabled", not active)


func _on_lock_trigger_body_entered(body: Node) -> void:
	if _encounter_triggered or not has_encounter or not body.is_in_group("player"):
		return
	_encounter_triggered = true
	_start_encounter()


func _start_encounter() -> void:
	await lock()
	_spawn_enemies()


func _spawn_enemies() -> void:
	for i in _enemies_alive:
		var enemy_scene: PackedScene = _enemy_scenes.pick_random()
		var enemy: Enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.position = _random_spawn_position()
		enemy.died.connect(_on_enemy_died)


func _random_spawn_position() -> Vector2:
	var half_size := spawn_area_size * 0.5
	return spawn_area_offset + Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)


func _on_enemy_died() -> void:
	_enemies_alive -= 1
	if _enemies_alive <= 0:
		unlock()
		cleared.emit()


func lock() -> void:
	if locked:
		return
	locked = true
	_set_locked_collision(true)
	animation_player.play("UNLOCKING", -1, -1.0, true)
	await animation_player.animation_finished
	animation_player.play("LOCKED")


func unlock() -> void:
	if not locked:
		return
	locked = false
	animation_player.play("UNLOCKING")
	await animation_player.animation_finished
	animation_player.play("UNLOCKED")
	_set_locked_collision(false)


func _set_locked_collision(is_locked: bool) -> void:
	var no_doors_body: StaticBody2D = collision_forms.get_node("NoDoors")
	no_doors_body.visible = is_locked
	for shape in no_doors_body.get_children():
		if shape is CollisionShape2D:
			shape.set_deferred("disabled", not is_locked)

	if is_locked:
		var type_name: String = RoomType.keys()[current_room_type]
		var door_body: StaticBody2D = collision_forms.get_node_or_null(type_name)
		if door_body:
			for shape in door_body.get_children():
				if shape is CollisionShape2D:
					shape.set_deferred("disabled", true)
	else:
		_update_room_type()


func _unlock_current_room_type() -> void:
	pass
