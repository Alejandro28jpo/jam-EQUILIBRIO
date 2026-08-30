extends Node
class_name MainLevel


const BASE_ROOM_COUNT := 3
const LEVELS_PER_ROOM_INCREASE := 2

@export var player_scene: PackedScene = preload("res://entities/player/player.tscn")

@onready var room_manager: RoomManager = $RoomManager

var current_level: int = 1
var player: Node2D


func _ready() -> void:
	_start_level(current_level)


func next_level() -> void:
	_start_level(current_level + 1)


func _start_level(level: int) -> void:
	current_level = level
	var room_count := BASE_ROOM_COUNT + (level - 1) / LEVELS_PER_ROOM_INCREASE
	var start_position := room_manager.generate(self, room_count)
	generate_player(start_position)


func generate_player(start_position: Vector2) -> void:
	if player == null:
		player = player_scene.instantiate()
		add_child(player)
		var camera := Camera2D.new()
		player.add_child(camera)
	player.position = start_position
