extends CanvasLayer
class_name MainMenu


@onready var start_button: TextureButton = $StartButton
@onready var quit_button: TextureButton = $QuitButton
@onready var settings_button: TextureButton = $SettingsButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)


func _on_start_button_pressed() -> void:
	#get_tree().change_scene_to_file("uid://b4t2us54hecpu")
	Transition.change_scene("uid://b4t2us54hecpu", true, 1)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	print("Settings")
