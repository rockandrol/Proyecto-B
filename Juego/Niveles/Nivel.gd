class_name	Nivel
extends Node2D

## Variables Export ############################################################
export var explosion:PackedScene = null
export var meteorito:PackedScene = null
export var explosion_meteorito:PackedScene = null
export var sector_meteoritos:PackedScene = null
export var enemigo_interceptor:PackedScene = null
export var enemigo_misilero:PackedScene = null
export var rele_masa:PackedScene = null
export var tiempo_transicion_camara:float = 0.2
export var tiempo_limite:int = 10
export var musica_nivel:AudioStream = null
export var musica_combate:AudioStream = null
export(String,FILE,"*.tscn") var prox_nivel = ""


## Atributos ###################################################################
var meteoritos_totales:int = 0
var player:Player = null
var numero_bases_enemigas = 0


## Atributos Onready ###########################################################
onready var contenedor_enemigos:Node
onready var contenedor_proyectiles:Node
onready var contenedor_meteoritos:Node
onready var contenedor_sector_meteoritos:Node
onready var contenedor_bases_enemigas:Node
onready var contenedor_rele_masa:Node
onready var contenedor_explosiones:Node
onready var camara_nivel:Camera2D = $CameraNivel
onready var camara_player:Camera2D = $Player/CameraPlayer
onready var actualizador_timer:Timer = $ActualizadorTimer
onready var pausa:Control = $HUD/MenuPausa


## Metodos #####################################################################
func _ready() -> void:
	Eventos.emit_signal("nivel_iniciado")
	Eventos.emit_signal("actualizar_tiempo",tiempo_limite)
	actualizador_timer.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	MusicaJuego.set_streams(musica_nivel, musica_combate)
	MusicaJuego.play_musica_nivel()
	conectar_seniales()
	crear_contenedores()
	numero_bases_enemigas = contabilizar_bases_enemigas()
	player = DatosJuego.get_player_actual()


## Metodos Custom ##############################################################
func crear_contenedores() -> void:
	contenedor_proyectiles = Node.new()
	contenedor_proyectiles.name = "ContenedorProyectiles"
	add_child(contenedor_proyectiles)
	
	contenedor_meteoritos = Node.new()
	contenedor_meteoritos.name = "ContenedorMeteoritos"
	add_child(contenedor_meteoritos)
	
	contenedor_explosiones = Node.new()
	contenedor_explosiones.name = "ContenedorExplosiones"
	add_child(contenedor_explosiones)

	contenedor_sector_meteoritos = Node.new()
	contenedor_sector_meteoritos.name = "ContenedorSectorMeteoritos"
	add_child(contenedor_sector_meteoritos)
	
	contenedor_enemigos = Node.new()
	contenedor_enemigos.name = "ContenedorEnemigos"
	add_child(contenedor_enemigos)
	
	contenedor_rele_masa = Node.new()
	contenedor_rele_masa.name = "ContenedorRele"
	add_child(contenedor_rele_masa)

func crear_explosiones(posicion:Vector2, num_explosiones:int) -> void:
	for _i in range(num_explosiones):
		var new_explosion:Node2D = explosion.instance()
		new_explosion.global_position = posicion + crear_posicion_aleatoria(100.0,50.0)
		contenedor_explosiones.add_child(new_explosion)
		yield(get_tree().create_timer(0.02), "timeout")

func crear_posicion_aleatoria(rango_horizontal:float, rango_vertical:float) -> Vector2:
	randomize()
	var rand_x = rand_range(-rango_horizontal, rango_horizontal)
	var rand_y = rand_range(-rango_vertical, rango_vertical)
	
	return Vector2 (rand_x, rand_y)

func crear_rele() -> void:
	var new_rele_masa:ReleMasa = rele_masa.instance()
	var pos_aleatoria:Vector2 = crear_posicion_aleatoria(800.0,800.0)
	var margen:Vector2 = Vector2(600.0,600.0)
	if pos_aleatoria.x < 0:
		margen.x *= -1
	if pos_aleatoria.y < 0:
		margen.y *= -1
	
	new_rele_masa.global_position = player.global_position + (margen + pos_aleatoria)
	contenedor_rele_masa.add_child(new_rele_masa)

func crear_sector_enemigos(num_enemigos: int) -> void:
	for _i in range(num_enemigos):
		var new_interceptor:EnemigoInterceptor = enemigo_interceptor.instance()
		var spaw_pos:Vector2 = crear_posicion_aleatoria(1000.0,1000.0)
		new_interceptor.global_position = player.global_position + spaw_pos
		contenedor_enemigos.add_child(new_interceptor)

func crear_sector_misileros(num_enemigos: int) -> void:
	for _i in range(num_enemigos):
		var new_misilero:EnemigoMisilero = enemigo_misilero.instance()
		var spaw_pos:Vector2 = crear_posicion_aleatoria(800.0,800.0)
		new_misilero.global_position = player.global_position + spaw_pos
		contenedor_enemigos.add_child(new_misilero)

func crear_sector_meteoritos(centro_camara:Vector2, numero_peligros:int) -> void:
	MusicaJuego.transicion_musica()
	meteoritos_totales = numero_peligros
	var new_sector_meteoritos:SectorMeteoritos = sector_meteoritos.instance()
	new_sector_meteoritos.crear(centro_camara, numero_peligros)
	camara_nivel.global_position = centro_camara
	contenedor_sector_meteoritos.add_child(new_sector_meteoritos)
	camara_nivel.zoom = camara_player.zoom
	camara_nivel.devolver_zoom_original()
	transicion_camaras(
		camara_player.global_position,
		camara_nivel.global_position,
		camara_nivel,
		tiempo_transicion_camara
	)

func conectar_seniales() -> void:
# warning-ignore:return_value_discarded
	Eventos.connect("disparo", self, "_on_disparo")
# warning-ignore:return_value_discarded
	Eventos.connect("nave_destruida",self,"_on_nave_destruida")
# warning-ignore:return_value_discarded
	Eventos.connect("spawn_meteorito",self, "_on_spawn_meteoritos")
# warning-ignore:return_value_discarded
	Eventos.connect("meteorito_destruido", self, "_on_meteorito_destruido")
# warning-ignore:return_value_discarded
	Eventos.connect("nave_en_sector_peligro",self, "_on_nave_en_sector_peligro")
# warning-ignore:return_value_discarded
	Eventos.connect("base_destruida",self, "_on_base_destruida")
# warning-ignore:return_value_discarded
	Eventos.connect("spawn_orbital",self, "_on_spawn_orbital")
# warning-ignore:return_value_discarded
	Eventos.connect("nivel_completado",self,"_on_nivel_completado")
# warning-ignore:return_value_discarded
	Eventos.connect("mostrar_cursor",self,"_on_mostrar_cursor")
# warning-ignore:return_value_discarded
	Eventos.connect("ocultar_cursor",self,"_on_ocultar_cursor")
# warning-ignore:return_value_discarded
	Eventos.connect("explotar_misil",self,"_on_explotar_misil")

func contabilizar_bases_enemigas() -> int:
	return $ContenedorBasesEnemigas.get_child_count()

func controlar_meteoritos_restantes() -> void:
	meteoritos_totales -= 1
	Eventos.emit_signal("cambio_numero_meteoritos",meteoritos_totales)
	if meteoritos_totales == 0:
		MusicaJuego.transicion_musica()
		contenedor_sector_meteoritos.get_child(0).queue_free()
		camara_player.set_puede_hacer_zoom(true)
		var zoom_actual = camara_player.zoom
		camara_player.zoom = camara_nivel.zoom
		camara_player.zoom_suavisado(zoom_actual.x, zoom_actual.y, 1.0)
		transicion_camaras(
			camara_nivel.global_position,
			camara_player.global_position,
			camara_player,
			tiempo_transicion_camara
		)

func destruir_nivel() -> void:
# warning-ignore:narrowing_conversion
	crear_explosiones(
		player.global_position + crear_posicion_aleatoria(300.0,300.0),
		8.0
	)
	player.destruir()

func transicion_camaras(desde:Vector2, hasta: Vector2, camara_actual: Camera2D, tiempo_transicion:float) -> void:
	$TweenCamara.interpolate_property(
		camara_actual,
		"global_position",
		desde,
		hasta,
		tiempo_transicion_camara,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		tiempo_transicion
		)
	camara_actual.current = true
	$TweenCamara.start()


## Conectar Señales ############################################################
func _on_disparo(proyectil) -> void:
	contenedor_proyectiles.add_child(proyectil)

func _on_explotar_misil(pos:Vector2,numExplociones:int) -> void:
	crear_explosiones(pos,numExplociones)
	

func _on_nave_destruida(nave: Player, posicion: Vector2, num_explosiones: int) -> void:
	if nave is Player:
		get_tree().call_group("contenedor_info", "set_esta_activo", false)
		get_tree().call_group("contenedor_info", "ocultar")
		transicion_camaras(
			posicion,
			posicion + crear_posicion_aleatoria(-200.0, 200.0),
			camara_nivel,
			tiempo_transicion_camara
		)
		$RestarTimer.start()
	crear_explosiones(posicion, num_explosiones)	

func _on_spawn_orbital(enemigo: EnemigoOrbital) -> void:
	contenedor_enemigos.add_child(enemigo)

# warning-ignore:unused_argument
func _on_base_destruida(base, posicion, num_explosiones: int = 5) -> void:
	crear_explosiones(posicion, num_explosiones)
	yield(get_tree().create_timer(0.5),"timeout")
	numero_bases_enemigas -= 1
	if numero_bases_enemigas == 0:
		crear_rele()

func _on_spawn_meteoritos(pos_spawn: Vector2, dir_meteorito: Vector2, tamanio: float) -> void:
	var new_meteorito:Meteorito = meteorito.instance()
	new_meteorito.crear(
		pos_spawn,
		dir_meteorito,
		tamanio
	)
	contenedor_meteoritos.add_child(new_meteorito)

func _on_meteorito_destruido(pos: Vector2) -> void:
	var new_explosion:ExplosionMeteorito = explosion_meteorito.instance()
	new_explosion.global_position = pos
	add_child(new_explosion)
	controlar_meteoritos_restantes()

func _on_nave_en_sector_peligro(centro_camara:Vector2, tipo_peligro:String, numero_peligros:int) -> void:
	if tipo_peligro == "Meteorito":
		crear_sector_meteoritos(centro_camara, numero_peligros)
		Eventos.emit_signal("cambio_numero_meteoritos",numero_peligros)
	elif tipo_peligro == "Interceptor":
		crear_sector_enemigos(numero_peligros)
	elif tipo_peligro == "Misilero":
		crear_sector_misileros(numero_peligros)

# warning-ignore:unused_argument
func _on_TweenCamara_tween_completed(object: Object, _key: NodePath) -> void:
	if object.name == "CameraPlayer":
		object.global_position = camara_player.global_position

func _on_RestarTimer_timeout() -> void:
	Eventos.emit_signal("nivel_terminado")
	yield(get_tree().create_timer(0.3),"timeout")
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func _on_ActualizadorTimer_timeout() -> void:
	tiempo_limite -= 1
	Eventos.emit_signal("actualizar_tiempo",tiempo_limite)
	if tiempo_limite == 0:
		destruir_nivel()

func _on_nivel_completado() -> void:
	Eventos.emit_signal("nivel_terminado")
	yield(get_tree().create_timer(1.0),"timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene(prox_nivel)

func _on_mostrar_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ocultar_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
