## HUD
extends CanvasLayer

## Atributos Export ############################################################
export var info_nivel:String = ""


## Atributos Onready ###########################################################
onready var info_zona_recarga:ContenedorInformacion = $ZonaRecargaText
onready var info_meteoritos:ContenedorInformacion = $MeteoritosText
onready var info_tiempo_restante:ContenedorInformacion = $TiempoText
onready var barra_energia_laser:ContenedorInformacionEnergia = $LaserBar
onready var barra_energia_escudo:ContenedorInformacionEnergia = $EscudoBar
onready var barra_energia_turbo:ContenedorInformacionEnergia = $TurboBar
onready var info:ContenedorInformacion = $InfoNivel 


## Metodos #####################################################################
func _ready() -> void:
	conectar_seniales()


## Metodos Custom ##############################################################
func conectar_seniales() -> void:
# warning-ignore:return_value_discarded
	Eventos.connect("nivel_iniciado", self, "fade_out")
# warning-ignore:return_value_discarded
	Eventos.connect("nivel_terminado", self, "fade_in")
# warning-ignore:return_value_discarded
	Eventos.connect("detector_zona_recarga",self,"_on_detector_zona_recarga")
# warning-ignore:return_value_discarded
	Eventos.connect("cambio_numero_meteoritos",self,"_on_actualizar_info_meteoritos")
# warning-ignore:return_value_discarded
	Eventos.connect("actualizar_tiempo",self,"_on_actualizar_info_tiempo")
# warning-ignore:return_value_discarded
	Eventos.connect("cambio_energia_laser",self,"_on_actualizar_energia_laser")
# warning-ignore:return_value_discarded
	Eventos.connect("ocultar_energia_laser",barra_energia_laser,"ocultar")
# warning-ignore:return_value_discarded
	Eventos.connect("cambio_energia_escudo",self,"_on_actualizar_energia_escudo")
# warning-ignore:return_value_discarded
	Eventos.connect("ocultar_energia_escudo",barra_energia_escudo,"ocultar")
# warning-ignore:return_value_discarded
	Eventos.connect("cambio_energia_turbo",self,"_on_actualizar_energia_turbo")
# warning-ignore:return_value_discarded
	Eventos.connect("ocultar_energia_turbo",barra_energia_turbo,"ocultar")


func fade_in() -> void:
	$FadeCanvas/AnimationPlayer.play("fade_in")

func fade_out() -> void:
	$FadeCanvas/AnimationPlayer.play_backwards("fade_in")
	info.mostrar()
	info.modificar_texto(info_nivel)
	yield(get_tree().create_timer(3),"timeout")
	info.ocultar_suavizado()


## Señales Internas ############################################################
func _on_detector_zona_recarga(en_zona: bool) -> void:
	if en_zona:
		info_zona_recarga.mostrar_suavizado()
	else:
		info_zona_recarga.ocultar_suavizado()

func _on_actualizar_info_meteoritos(numero:int) -> void:
	info_meteoritos.mostrar_suavizado()
	info_meteoritos.modificar_texto("METEORITOS RESTANTES\n {cantidad}".format({"cantidad":numero}))

func _on_actualizar_info_tiempo(tiempo_restante:int) -> void:
# warning-ignore:narrowing_conversion
	var minutos:int = floor(tiempo_restante * 0.016666666)
	var segundos:int = tiempo_restante % 60
	info_tiempo_restante.modificar_texto("TIEMPO RESTANTE\n%02d:%02d" % [minutos,segundos])
	
	if tiempo_restante % 10 == 0:		
		info_tiempo_restante.mostrar_suavizado()
#	if tiempo_restante == 11:
#		info_tiempo_restante.set_auto_ocultar(false)
	elif tiempo_restante == 0:
		info_tiempo_restante.ocultar()

func _on_actualizar_energia_laser(energia_max:float, energia_actual:float) -> void:
	barra_energia_laser.mostrar()
	barra_energia_laser.actualizar_energia(energia_max,energia_actual)

func _on_actualizar_energia_escudo(energia_max:float, energia_actual:float) -> void:
	barra_energia_escudo.mostrar()
	barra_energia_escudo.actualizar_energia(energia_max,energia_actual)

func _on_actualizar_energia_turbo(energia_max:float, energia_actual:float) -> void:
	barra_energia_turbo.mostrar()
	barra_energia_turbo.actualizar_energia(energia_max,energia_actual)
	
func _on_nave_destruida(nave:NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		get_tree().call_group("contenedor_info", "set_esta_activo", false)
		get_tree().call_group("contenedor_info","ocultar")
	



