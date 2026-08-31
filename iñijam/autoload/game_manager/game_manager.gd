extends Node


const SAVE_PATH := "user://save.json"

signal score_changed(new_score: int)
signal level_changed(new_level: int)
signal score_popup_requested(points: int, world_position: Vector2)

var current_level: int = 1
var current_score: int = 0
var best_score: int = 0
var intro_seen: bool = false


func _ready() -> void:
	_load_save()


func start_new_game() -> void:
	current_level = 1
	current_score = 0
	score_changed.emit(current_score)
	level_changed.emit(current_level)


func save_best_score() -> void:
	_save()


func mark_intro_seen() -> void:
	if intro_seen:
		return
	intro_seen = true
	_save()


func _save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"best_score": best_score, "intro_seen": intro_seen}))


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	if data.has("best_score"):
		best_score = int(data["best_score"])
	if data.has("intro_seen"):
		intro_seen = bool(data["intro_seen"])


func add_score(amount: int) -> void:
	current_score += amount
	best_score = max(best_score, current_score)
	score_changed.emit(current_score)


func reset_score() -> void:
	current_score = 0
	score_changed.emit(current_score)


func set_level(level: int) -> void:
	current_level = level
	level_changed.emit(current_level)
