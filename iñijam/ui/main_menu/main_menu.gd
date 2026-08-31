extends CanvasLayer
class_name MainMenu

const PRESELECT = preload("uid://c31ll73dr57b7")
const PULSAR_ATRÁS_EXIT = preload("uid://bhh0027xjbm0h")

@onready var start_button: TextureButton = $StartButton
@onready var quit_button: TextureButton = $QuitButton
@onready var settings_button: TextureButton = $SettingsButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	$"RadioCasseteMúsicaPop".play()


func _on_start_button_pressed() -> void:
	GameManager.start_new_game()
	Transition.change_scene("uid://cxkx4vnakrmrg", true, 1)


func _on_quit_button_pressed() -> void:
	ControladorAudio.reproducir_sonido(PULSAR_ATRÁS_EXIT)
	$AnimationPlayer.play("salir")


func _on_settings_button_pressed() -> void:
	Transition.change_scene("uid://c4c2p31hmfmem", false, 1)
	print("Settings")
	
func quit():
	get_tree().quit()
func _on_start_button_focus_entered() -> void:
	ControladorAudio.reproducir_sonido(PRESELECT)
func _on_quit_button_focus_entered() -> void:
	ControladorAudio.reproducir_sonido(PRESELECT)
func _on_settings_button_focus_entered() -> void:
	ControladorAudio.reproducir_sonido(PRESELECT)
