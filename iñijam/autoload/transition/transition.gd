extends CanvasLayer


signal completed

@export var fade_duration: float = 0.5

@onready var _container: Control = $Container
@onready var _numbers: Node2D = $Container/Numbers
@onready var _decimal_sprite_1: Sprite2D = $Container/Numbers/Decimal/Sprite2D
@onready var _decimal_sprite_2: Sprite2D = $Container/Numbers/Decimal/Sprite2D2
@onready var _integers_sprite_1: Sprite2D = $Container/Numbers/Integers/Sprite2D
@onready var _integers_sprite_2: Sprite2D = $Container/Numbers/Integers/Sprite2D2

var _is_on_transition: bool = false


func change_scene(scene_path: String, show_level: bool = false, level: int = 1) -> void:
	while _is_on_transition:
		await completed

	await fade_in(show_level, level)
	await get_tree().create_timer(.5).timeout
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await fade_out(show_level, level)


func fade_in(show_level: bool = false, level: int = 1) -> void:
	_is_on_transition = true
	_setup_level_display(show_level, level)

	_container.visible = true
	_container.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.tween_property(_container, "modulate:a", 1.0, fade_duration)
	await tween.finished

	_is_on_transition = false
	completed.emit()


func fade_out(show_level: bool = false, level: int = 1) -> void:
	_is_on_transition = true
	_setup_level_display(show_level, level)

	_container.visible = true
	_container.modulate.a = 1.0

	var tween: Tween = create_tween()
	tween.tween_property(_container, "modulate:a", 0.0, fade_duration)
	await tween.finished

	_container.visible = false
	_is_on_transition = false
	completed.emit()


func _setup_level_display(show_level: bool, level: int) -> void:
	_numbers.visible = show_level
	if show_level:
		_set_level_digits(level)


func _set_level_digits(level: int) -> void:
	var clamped_level: int = clampi(level, 0, 9999)
	_decimal_sprite_1.frame = (clamped_level / 1000) % 10
	_decimal_sprite_2.frame = (clamped_level / 100) % 10
	_integers_sprite_1.frame = (clamped_level / 10) % 10
	_integers_sprite_2.frame = clamped_level % 10
