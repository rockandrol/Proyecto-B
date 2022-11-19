class_name Motor
extends AudioStreamPlayer2D

## Atributos Export ############################################################
export var tiempo_transicion:float = 0.6
export var volumen_apagado:float = -30.0
export var volumen_turbo:float = 50.0
export var pitch_scale_turbo:float = 3

## Atributos Onready ###########################################################
onready var tween_sonido:Tween = $Tween


## Atributos ###################################################################
var volumen_original:float
var pitch_scale_original:float

## Metodos #####################################################################
func _ready() -> void:
	volumen_original = volume_db
	volume_db = volumen_apagado
	pitch_scale_original = pitch_scale
	pitch_scale = pitch_scale_turbo

## Metodos Custom ##############################################################
func sonido_turbo_on() -> void:
	volume_db = volumen_turbo
	if not playing:
		play()		
	efecto_transicion(volumen_turbo, volume_db)
	efecto_transicion(pitch_scale_turbo, pitch_scale)
	
func sonido_turbo_off() -> void:
	efecto_transicion(volumen_apagado, volume_db)
	efecto_transicion(pitch_scale_original,pitch_scale)
	
func sonido_on() -> void:
	if not playing:
		play()		
	efecto_transicion(volume_db, volumen_original)
	
func sonido_off() -> void:
	efecto_transicion(volume_db, volumen_apagado)

func efecto_transicion(desde_vol: float, hasta_vol:float) -> void:
# warning-ignore:return_value_discarded
	tween_sonido.interpolate_property(
		self,
		"volume_db",
		desde_vol,
		hasta_vol,
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT_IN
		)
# warning-ignore:return_value_discarded
	tween_sonido.start()
