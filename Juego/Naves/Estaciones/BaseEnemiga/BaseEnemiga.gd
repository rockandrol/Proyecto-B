class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 30.0
export var orbital:PackedScene = null

## Atributos Onready
onready var impacto_sfx:AudioStreamPlayer2D = $Impacto_sfx

## Atributos
var esta_destruida:bool = false

## Metodos
func _ready() -> void:
	$AnimationPlayer.play(elegir_animacion_aleatoria())

func _process(_delta: float) -> void:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	if not player_objetivo:
		return
	var dir_player:Vector2 =  player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())
	print(angulo_player)
	

## Metodos Custom
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
	impacto_sfx.play()

func destruir() -> void:
	var posicion_base = $Sprites.global_position
	Eventos.emit_signal("base_destruida", self, posicion_base)
	queue_free()

func spawnear_orbital() -> void:
	var pos_spawn:Vector2 = deteccion_cuadrante()
	var new_orbital:EnemigoOrbital = orbital.instance()
	new_orbital.crear(
		global_position + pos_spawn,
		self
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
		return $PosicionesSpawn/Este.position
	elif abs(angulo_player) > 135.0 and abs(angulo_player) <= 180:
		# por izquierda
		return $PosicionesSpawn/Oeste.position
	elif abs(angulo_player) > 45.0 and abs(angulo_player) <= 135:
		# por abajo
		if sign(angulo_player) > 0:
			return $PosicionesSpawn/Sur.position
		else:
			return $PosicionesSpawn/Norte.position
	return $PosicionesSpawn/Norte.position

## Señales Internas
func _on_AreaColision_body_entered(body:Node) -> void:
	if body.has_method("destruir"):
		body.destruir()


func _on_VisibilityNotifier2D_screen_entered() -> void:
	#spawn orbital
	$VisibilityNotifier2D.queue_free()
	spawnear_orbital()
#	var new_orbital:EnemigoOrbital = orbital.instance()
#	new_orbital.crear(
#		global_position + $PosicionesSpawn/Norte.global_position,
#		selfa
#	)
#	Eventos.emit_signal("spawn_orbital",new_orbital)
