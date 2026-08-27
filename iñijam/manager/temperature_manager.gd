extends Node
class_name TemperatureManager


enum TEMPERATURE {COLD, HEAT}

signal balance_changed(new_value: float)
signal player_died_by_temperature(case: TEMPERATURE)

const MIN_BALANCE: float = -100.
const MAX_BALANCE: float = 100.

var balance: float = 0.0:
	set(value):
		balance = value
		balance_changed.emit(balance)


var _is_dead: bool = false

## Funcion que aplica calor al jugador donde [code]MAX_BALANCE[/code] es el valor maximo permitido
func add_heat(amount: float) -> void:
	balance = minf(balance + amount, MAX_BALANCE)
	if balance >= MAX_BALANCE:
		_die(TEMPERATURE.HEAT)

## Funcion que aplica frio al jugador donde [code]MIN_BALANCE[/code] es el valor minimo permitido
func add_cold(amount: float) -> void:
	balance = maxf(balance - amount, MIN_BALANCE)
	if balance <= MIN_BALANCE:
		_die(TEMPERATURE.COLD)

func _die(cause: TEMPERATURE) -> void:
	if _is_dead:
		return
	_is_dead = true
	player_died_by_temperature.emit(cause)

## Reinicia el balance a 0 y permite que una nueva muerte por temperatura pueda dispararse
func reset_balance() -> void:
	_is_dead = false
	balance = 0.0
