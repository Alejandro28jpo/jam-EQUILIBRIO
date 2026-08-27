extends Node
class_name TemperatureComponent


signal balance_change(new_value: float)
signal state_changed(new_state: GlobalEnums.EntityState, old_state: GlobalEnums.EntityState)
signal died(cause: GlobalEnums.EntityState)

@onready var body: Node = get_parent()

var balance: float = 0.0:
	set(value):
		balance = value
		balance_change.emit(balance)
		_update_state()

var state: GlobalEnums.EntityState = GlobalEnums.EntityState.NEUTRAL

var _is_dead: bool = false


func affect_temperature(amount: float) -> void:
	balance += amount


func _update_state() -> void:
	var old_state: GlobalEnums.EntityState = state
	
	if balance < -20.0:
		state = GlobalEnums.EntityState.PEAK_FREEZE
	elif balance < -5.0:
		state = GlobalEnums.EntityState.FREEZING
	elif balance < 5.0:
		state = GlobalEnums.EntityState.DEEP_COLD
	elif balance < 15.0:
		state = GlobalEnums.EntityState.COLD
	elif balance < 25.0:
		state = GlobalEnums.EntityState.NEUTRAL
	elif balance < 35.0:
		state = GlobalEnums.EntityState.HOT
	elif balance < 45.0:
		state = GlobalEnums.EntityState.DEEP_HEAT
	elif balance < 60.0:
		state = GlobalEnums.EntityState.BURNING
	elif balance <= 100.0:
		state = GlobalEnums.EntityState.PEAK_BURN
	else:
		state = GlobalEnums.EntityState.INCANDESCENT
	
	if state != old_state: state_changed.emit(state, old_state)
	
	if state == GlobalEnums.EntityState.PEAK_FREEZE or state == GlobalEnums.EntityState.INCANDESCENT:
		_die(state)


func _die(cause: GlobalEnums.EntityState) -> void:
	if _is_dead: return
	
	_is_dead = true
	died.emit(cause)


func reset_balance() -> void:
	_is_dead = false
	balance = 0.0
