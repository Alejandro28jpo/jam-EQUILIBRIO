extends Node
class_name TemperatureAmbienceComponent


const LOW_STREAM_PATH := "res://sonidos/escenas/SALAS PRINCIPALES/TEMPERATURA BAJA.ogg"
const AMBIENT_STREAM_PATH := "res://sonidos/escenas/SALAS PRINCIPALES/TEMPERATURA AMBIENTE.ogg"
const HIGH_STREAM_PATH := "res://sonidos/escenas/SALAS PRINCIPALES/TEMPERATURA ALTA.ogg"

const MIN_DB := -80.0

const MIX_TABLE: Array[Vector3] = [
	Vector3(90.0, 10.0, 0.0),
	Vector3(75.0, 25.0, 0.0),
	Vector3(50.0, 50.0, 0.0),
	Vector3(33.0, 66.0, 0.0),
	Vector3(25.0, 75.0, 0.0),
	Vector3(0.0, 100.0, 0.0),
	Vector3(0.0, 75.0, 25.0),
	Vector3(0.0, 66.0, 33.0),
	Vector3(0.0, 50.0, 50.0),
	Vector3(0.0, 25.0, 75.0),
	Vector3(0.0, 10.0, 90.0),
]

@onready var _low_player: AudioStreamPlayer = $Low
@onready var _ambient_player: AudioStreamPlayer = $Ambient
@onready var _high_player: AudioStreamPlayer = $High

var _temperature_component: TemperatureComponent


func setup(temperature_component: TemperatureComponent) -> void:
	_temperature_component = temperature_component
	_temperature_component.balance_change.connect(_on_balance_change)

	_start_loop(_low_player, LOW_STREAM_PATH)
	_start_loop(_ambient_player, AMBIENT_STREAM_PATH)
	_start_loop(_high_player, HIGH_STREAM_PATH)

	_update_mix(_temperature_component.balance)


func _start_loop(player: AudioStreamPlayer, stream_path: String) -> void:
	if not ResourceLoader.exists(stream_path):
		push_warning("TemperatureAmbienceComponent: missing stream at " + stream_path)
		return

	var stream: AudioStream = load(stream_path).duplicate()
	if "loop" in stream:
		stream.loop = true
	player.stream = stream
	player.volume_db = MIN_DB
	player.play()


func _on_balance_change(new_value: float) -> void:
	_update_mix(new_value)


func _update_mix(balance: float) -> void:
	var t: float = clampf((balance + 20.0) / 8.0, 0.0, 10.0)
	var mix: Vector3 = _sample_mix(t)

	_low_player.volume_db = _percent_to_db(mix.x)
	_ambient_player.volume_db = _percent_to_db(mix.y)
	_high_player.volume_db = _percent_to_db(mix.z)


func _sample_mix(t: float) -> Vector3:
	var index_a: int = int(floor(t))
	var index_b: int = mini(index_a + 1, MIX_TABLE.size() - 1)
	var weight: float = t - index_a
	return MIX_TABLE[index_a].lerp(MIX_TABLE[index_b], weight)


func _percent_to_db(percent: float) -> float:
	if percent <= 0.0:
		return MIN_DB
	return maxf(linear_to_db(percent / 100.0), MIN_DB)
