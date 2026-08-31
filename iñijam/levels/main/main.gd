extends Node
class_name MainLevel


const BASE_ROOM_COUNT := 3
const LEVELS_PER_ROOM_INCREASE := 2
const CAMERA_TRANSITION_TIME := 0.4

const BASE_ENEMY_COUNT := 2
const LEVELS_PER_ENEMY_INCREASE := 2

@export var player_scene: PackedScene = preload("res://entities/player/player.tscn")
@export var enemy_scenes: Array[PackedScene] = [preload("res://entities/enemies/bull/bull.tscn")]
@export var room_exit_scene: PackedScene = preload("res://game_objects/room_exit/room_exit.tscn")

@onready var room_manager: RoomManager = $RoomManager
@onready var y_sort: Node2D = $YSort

var player: Player
var camera: Camera2D
var current_cell: Vector2i
var _camera_tween: Tween


func _ready() -> void:
	_start_level(GameManager.current_level)


func _process(_delta: float) -> void:
	if player == null:
		return
	var cell := room_manager.cell_at(player.position)
	if cell != current_cell and room_manager.has_room(cell):
		_move_camera_to(cell)


func next_level() -> void:
	_start_level(GameManager.current_level + 1)


func _start_level(level: int) -> void:
	GameManager.set_level(level)
	var room_count := BASE_ROOM_COUNT + (level - 1) / LEVELS_PER_ROOM_INCREASE
	var start_position := room_manager.generate(y_sort, room_count)

	_setup_encounters()
	generate_player(start_position)

	current_cell = room_manager.cell_at(start_position)
	if camera == null:
		camera = Camera2D.new()
		add_child(camera)
	if _camera_tween:
		_camera_tween.kill()
	camera.position = start_position
	camera.make_current()


func generate_player(start_position: Vector2) -> void:
	if player == null:
		player = player_scene.instantiate()
		y_sort.add_child(player)
	player.position = start_position


func _move_camera_to(cell: Vector2i) -> void:
	current_cell = cell
	var target := room_manager.room_center(cell)
	if _camera_tween:
		_camera_tween.kill()
	_camera_tween = create_tween()
	_camera_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_camera_tween.tween_property(camera, "position", target, CAMERA_TRANSITION_TIME)


func _setup_encounters() -> void:
	var enemy_count = BASE_ENEMY_COUNT + (GameManager.current_level - 1) / LEVELS_PER_ENEMY_INCREASE
	var end_cell := room_manager.farthest_cell(room_manager.start_cell)
	for cell in room_manager.rooms_by_cell:
		if cell == room_manager.start_cell:
			continue
		var room: Room = room_manager.rooms_by_cell[cell]
		room.setup_encounter(enemy_scenes, enemy_count)
		if cell == end_cell:
			room.cleared.connect(_on_final_room_cleared.bind(room), CONNECT_ONE_SHOT)


func _on_final_room_cleared(room: Room) -> void:
	var room_exit: RoomExit = room_exit_scene.instantiate()
	room_exit.player = player
	room_exit.main_level = self
	room.call_deferred("add_child", room_exit)
