extends Node


signal score_changed(new_score: int)
signal level_changed(new_level: int)

var current_level: int = 1
var current_score: int = 0
var best_score: int = 0


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
