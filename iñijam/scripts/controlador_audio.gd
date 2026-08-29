extends Node


const MAX_SONIDOS_SIMULTANEOS = 5
const DURACION_CROSSFADE = 1.0

@export var volumen_musica_db: float = 0.0
@export var volumen_sonidos_db: float = 0.0

var _musica_a: AudioStreamPlayer
var _musica_b: AudioStreamPlayer
var _musica_activa: AudioStreamPlayer
var _stream_musica_actual: AudioStream = null
var _tween_musica: Tween

var _pool_sonidos: Array[AudioStreamPlayer] = []
var _siguiente_sonido: int = 0


func _ready() -> void:
	_musica_a = _crear_reproductor_musica()
	_musica_b = _crear_reproductor_musica()
	_musica_activa = _musica_a

	for i in range(MAX_SONIDOS_SIMULTANEOS):
		_pool_sonidos.append(_crear_reproductor_sonido())


func _crear_reproductor_musica() -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.bus = "Master"
	reproductor.volume_db = volumen_musica_db
	add_child(reproductor)
	return reproductor


func _crear_reproductor_sonido() -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.bus = "Master"
	reproductor.volume_db = volumen_sonidos_db
	add_child(reproductor)
	return reproductor


## CAMBIA LA MÚSICA CON UN FUNDIDO CRUZADO: LA ACTUAL BAJA VOLUMEN MIENTRAS LA NUEVA SUBE.
## SI YA SE ESTÁ REPRODUCIENDO ESE MISMO STREAM, NO HACE NADA (EVITA REINICIOS INNECESARIOS).
func reproducir_musica(stream: AudioStream, duracion_fundido: float = DURACION_CROSSFADE) -> void:
	if stream == _stream_musica_actual:
		return
	_stream_musica_actual = stream

	var anterior := _musica_activa
	var siguiente := _musica_b if _musica_activa == _musica_a else _musica_a
	_musica_activa = siguiente

	siguiente.stream = stream
	siguiente.volume_db = -80.0
	siguiente.play()

	if _tween_musica:
		_tween_musica.kill()
	_tween_musica = create_tween().set_parallel(true)
	_tween_musica.tween_property(siguiente, "volume_db", volumen_musica_db, duracion_fundido)
	_tween_musica.tween_property(anterior, "volume_db", -80.0, duracion_fundido)
	_tween_musica.chain().tween_callback(anterior.stop)


## BAJA LA MÚSICA ACTUAL CON FUNDIDO Y LA DETIENE
func detener_musica(duracion_fundido: float = DURACION_CROSSFADE) -> void:
	_stream_musica_actual = null
	var actual := _musica_activa

	if _tween_musica:
		_tween_musica.kill()
	_tween_musica = create_tween()
	_tween_musica.tween_property(actual, "volume_db", -80.0, duracion_fundido)
	_tween_musica.tween_callback(actual.stop)


## REPRODUCE UN SONIDO CORTO (SFX) USANDO EL POOL DE HASTA MAX_SONIDOS_SIMULTANEOS REPRODUCTORES.
## SI TODOS ESTÁN OCUPADOS, ROBA EL MÁS ANTIGUO (round-robin) EN VEZ DE IGNORAR EL SONIDO NUEVO.
func reproducir_sonido(stream: AudioStream, volumen_db: float = 0.0) -> void:
	var reproductor := _obtener_reproductor_libre()
	reproductor.stream = stream
	reproductor.volume_db = volumen_sonidos_db + volumen_db
	reproductor.play()


func _obtener_reproductor_libre() -> AudioStreamPlayer:
	for reproductor in _pool_sonidos:
		if not reproductor.playing:
			return reproductor

	#TODOS OCUPADOS: SE REUTILIZA EL SIGUIENTE EN ORDEN (round-robin), CORTANDO EL MÁS ANTIGUO
	var reproductor := _pool_sonidos[_siguiente_sonido]
	_siguiente_sonido = (_siguiente_sonido + 1) % MAX_SONIDOS_SIMULTANEOS
	return reproductor
