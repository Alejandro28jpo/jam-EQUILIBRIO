extends Node
class_name TemperatureComponent


signal balance_change(new_value: float)
signal state_changed(new_state: GlobalEnums.EntityState, old_state: GlobalEnums.EntityState)
signal died(cause: GlobalEnums.EntityState)
signal frozen_changed(is_frozen: bool)

@export var freeze_duration: float = 3.0
@export var freeze_kills: bool = true

@onready var body: Node = get_parent()

var balance: float = 15.0:
	set(value):
		balance = value
		balance_change.emit(balance)
		_update_state()

var state: GlobalEnums.EntityState = GlobalEnums.EntityState.NEUTRAL

var _is_dead: bool = false
var _freeze_timer: SceneTreeTimer


func setup() -> void:
	_update_state()


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
	else:
		state = GlobalEnums.EntityState.PEAK_BURN
	
	if state != old_state:
		state_changed.emit(state, old_state)
		if state == GlobalEnums.EntityState.PEAK_FREEZE and not freeze_kills:
			_start_freeze()
		elif old_state == GlobalEnums.EntityState.PEAK_FREEZE and not freeze_kills:
			_cancel_freeze()

	if state == GlobalEnums.EntityState.PEAK_BURN or (state == GlobalEnums.EntityState.PEAK_FREEZE and freeze_kills):
		_die(state)


func _start_freeze() -> void:
	frozen_changed.emit(true)
	_freeze_timer = get_tree().create_timer(freeze_duration)
	_freeze_timer.timeout.connect(_on_freeze_timeout)


func _cancel_freeze() -> void:
	if _freeze_timer:
		_freeze_timer.timeout.disconnect(_on_freeze_timeout)
		_freeze_timer = null
	frozen_changed.emit(false)


func _on_freeze_timeout() -> void:
	_freeze_timer = null
	balance = 15.0


func _die(cause: GlobalEnums.EntityState) -> void:
	if _is_dead: return
	_is_dead = true
	died.emit(cause)


func reset_balance() -> void:
	_is_dead = false
	balance = 0.0
