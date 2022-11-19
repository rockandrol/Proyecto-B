class_name Misil
extends RigidBody2D



## Atributos Export ############################################################
export var potencia_actual: float = 800.0
export var estela_maxima:int = 150
export var hitpoints:float = 0.5

## Atributos ###################################################################
var velocidad:Vector2 = Vector2.ZERO
var danio:float
var potencia_max: float = 800.0
var player_objetivo:Player = null
var dir_player:Vector2
var frame_actual:int = 0

## Atributos Onready ###########################################################
onready var estela:Estelar = $Estela/Trail2D


## Constructor #################################################################
func crear(pos: Vector2, dir: float, vel: float, danio_p: int) -> void:
	position = pos
	rotation = dir
	velocidad = Vector2(vel,0).rotated(dir)
	danio = danio_p



## Metodos #####################################################################
func _ready() -> void:
	player_objetivo = DatosJuego.get_player_actual()
	Eventos.emit_signal("minimpa_objeto_creado")
# warning-ignore:return_value_discarded
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	estela.set_max_points(estela_maxima)
	estela.set_emitting(true)
	
func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	linear_velocity += dir_player.normalized() * potencia_actual * _state.get_step()
#	linear_velocity.x = clamp(linear_velocity.x, -potencia_max, potencia_max)
#	linear_velocity.y = clamp(linear_velocity.y, -potencia_max, potencia_max)


func _physics_process(_delta: float) -> void:
	frame_actual += 1
	if frame_actual % 3 == 0:
		rotar_hacia_player()

#func _process(_delta: float) -> void:
#	velocidad += position*_delta * dir_player
#	dir_player = player_objetivo.global_position
#	position = dir_player * potencia_max 

## Metodos Custom ##############################################################
func daniar(otro_cuerpo:CollisionObject2D) -> void:
	if otro_cuerpo.has_method("destruir"):
		otro_cuerpo.destruir()
		queue_free()

func rotar_hacia_player() -> void:
	if player_objetivo:
		dir_player = player_objetivo.global_position - global_position
		rotation = dir_player.angle()

func recibir_danio(_danio: float) -> void:
	hitpoints -= _danio
	if hitpoints <= 0.0:
		Eventos.emit_signal("explotar_misil",global_position,1)
		queue_free()





## Señales internas ############################################################
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("recibir_danio"):
		area.recibir_danio(danio)
		Eventos.emit_signal("minimapa_objeto_destruido")
	queue_free()

func _on_body_entered(body: Node) -> void:
	daniar(body)

func _on_nave_destruida(nave: NaveBase, _posicion, _explosiones) -> void:
	if nave is Player:
		player_objetivo = null
	

