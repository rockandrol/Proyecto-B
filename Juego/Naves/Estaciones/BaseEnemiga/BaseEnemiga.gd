class_name BaseEnemiga
extends Node2D

## Atributos Export ############################################################
export var hitpoints:float = 30.0
export var orbital:PackedScene = null
export var numer_orbitales:int = 10
export var intervalo_spawn:float = 0.8
export(Array, PackedScene) var rutas
export var siempre_visible:bool = true


## Atributos ###################################################################
var esta_destruida:bool = false
var posicion_spawner:Vector2 = Vector2.ZERO
var ruta_selecccionada:Path2D


## Atributos Onready ###########################################################
onready var impacto_sfx:AudioStreamPlayer2D = $Impacto_sfx
onready var timer_spawner:Timer = $TimerSpawnEnemigos
onready var barra_salud:ProgressBar = $SaludBar


## Metodos #####################################################################
func _ready() -> void:
	barra_salud.set_valores(hitpoints)
	barra_salud.modulate = Color(1,1,1,siempre_visible)
	timer_spawner.wait_time = intervalo_spawn
	$AnimationPlayer.play(elegir_animacion_aleatoria())
	seleccionar_ruta()

func _process(_delta: float) -> void:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	if  not player_objetivo:
		return
	

## Metodos Custom ##############################################################
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim:int = $AnimationPlayer.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi() % num_anim + 1
	var lista_animacion: Array = $AnimationPlayer.get_animation_list()
	return lista_animacion[indice_anim_aleatoria]

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	if hitpoints <= 0 and not esta_destruida:
		esta_destruida = true
		destruir()
	barra_salud.set_hitpoints_actual(hitpoints)
	impacto_sfx.play()

func seleccionar_ruta() -> void:
	randomize()
	var indice_ruta:int = randi() % rutas.size() - 1
	ruta_selecccionada = rutas[indice_ruta].instance()
	add_child(ruta_selecccionada)

func destruir() -> void:
	var posicion_base = $Sprites.global_position
	Eventos.emit_signal("base_destruida", self, posicion_base)
	Eventos.emit_signal("minimapa_objeto_destruido",self)
	queue_free()

func spawnear_orbital() -> void:
	numer_orbitales -= 1
	ruta_selecccionada.global_position = global_position
	
	var new_orbital:EnemigoOrbital = orbital.instance()
	new_orbital.crear(
		global_position + posicion_spawner,
		self,
		ruta_selecccionada
	)
	Eventos.emit_signal("spawn_orbital", new_orbital)

func deteccion_cuadrante() -> Vector2:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	
	if not player_objetivo:
		return Vector2.ZERO
		
	var dir_player:Vector2 = player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())
	
	if abs(angulo_player) <= 45.0:
		# por derecha
		ruta_selecccionada.rotation_degrees = 180.0
		return $PosicionesSpawn/Este.position
	elif abs(angulo_player) > 135.0 and abs(angulo_player) <= 180:
		# por izquierda
		ruta_selecccionada.rotation_degrees = 0.0
		return $PosicionesSpawn/Oeste.position
	elif abs(angulo_player) > 45.0 and abs(angulo_player) <= 135:
		# por abajo o arriba 
		if sign(angulo_player) > 0:
			ruta_selecccionada.rotation_degrees = 270.0
			return $PosicionesSpawn/Sur.position
		else:
			ruta_selecccionada.rotation_degrees = 90.0
			return $PosicionesSpawn/Norte.position
	return $PosicionesSpawn/Norte.position


## Se??ales Internas ############################################################
func _on_AreaColision_body_entered(body:Node) -> void:
	if body.has_method("destruir"):
		body.destruir()

func _on_VisibilityNotifier2D_screen_entered() -> void:
	#spawn orbital
	$VisibilityNotifier2D.queue_free()
	posicion_spawner = deteccion_cuadrante()
	spawnear_orbital()
	timer_spawner.start()
#	var new_orbital:EnemigoOrbital = orbital.instance()
#	new_orbital.crear(
#		global_position, self, $PosicionesSpawn/Norte.global_position
#
#	)
#	Eventos.emit_signal("spawn_orbital",new_orbital)

func _on_TimerSpawnEnemigos_timeout() -> void:
	if numer_orbitales == 0:
		timer_spawner.stop()
		return
	spawnear_orbital()
