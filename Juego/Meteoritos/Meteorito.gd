class_name Meteorito
extends RigidBody2D

## Atributos Export ############################################################
export var vel_lineal_base: Vector2 = Vector2(300.0,300.0)
export var vel_angular_base:float = 3.0
export var hitpoints_base:float = 30.0


## Atributos ###################################################################
var hitpoints:float
var esta_destruido:bool = false
var esta_en_sector:bool = true setget set_esta_en_sector 
var pos_spawn_original:Vector2
var vel_spawn_original:Vector2


## Atributos Onready ###########################################################
onready var animacion:AnimationPlayer = $AnimationPlayer
onready var audio_impacto:AudioStreamPlayer2D = $impacto_sfx


## Metodos #####################################################################
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if esta_en_sector:
		return
	var mi_trasform := state.get_transform()
	mi_trasform.origin = pos_spawn_original
	linear_velocity = vel_spawn_original
	state.set_transform(mi_trasform)
	esta_en_sector = true


## Setters y Getters ###########################################################
func set_esta_en_sector(valor: bool) -> void:
	esta_en_sector = valor


## Constructor #################################################################
func crear(pos:Vector2, dir:Vector2, tamanio:float) -> void:
	position = pos
	pos_spawn_original = pos
	# Caluclar masa, tamaño de sprite y de colisionador
	mass*= tamanio
	$Sprite.scale = Vector2.ONE * tamanio
	#radio = diametro/2
	var radio:int = int($Sprite.texture.get_size().x/2.3*tamanio)
	var forma_colision:CircleShape2D = CircleShape2D.new()
	forma_colision.radius = radio
	$CollisionShape2D.shape = forma_colision
	# Calcular Velocidades
	linear_velocity = vel_lineal_base * dir / tamanio * aleatorizar_velocidad()
	vel_spawn_original = linear_velocity
	angular_velocity = vel_angular_base / tamanio * aleatorizar_velocidad() 
	# Calcular Hitpoints
	hitpoints = hitpoints_base * tamanio


## Metodos Custom ##############################################################
func aleatorizar_velocidad() -> float:
	randomize()
	return rand_range(1.5,2.1)

func recibir_danio(danio: float) -> void:
	hitpoints -= danio
	audio_impacto.play()
	animacion.play("impacto")
	
	if hitpoints <= 0.0 and not esta_destruido:
		esta_destruido = true
		destruir()

func destruir() -> void:
	$CollisionShape2D.set_deferred("disable", true)
	Eventos.emit_signal("meteorito_destruido", global_position)
	queue_free()
