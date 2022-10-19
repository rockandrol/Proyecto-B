class_name Meteorito
extends RigidBody2D

## Atributos Onready
onready var animacion:AnimationPlayer = $AnimationPlayer
onready var audio_impacto:AudioStreamPlayer2D = $impacto_sfx


## Atributos Export
export var vel_lineal_base: Vector2 = Vector2(300.0,300.0)
export var vel_angular_base:float = 3.0
export var hitpoints_base:float = 30.0

## Atributos
var hitpoints:float

## Metodos
func _ready() -> void:
	angular_velocity = vel_angular_base

## Constructor
func crear(pos:Vector2, dir:Vector2, tamanio:float) -> void:
	position = pos
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
	angular_velocity = vel_angular_base / tamanio * aleatorizar_velocidad() 
	# Calcular Hitpoints
	hitpoints = hitpoints_base * tamanio
	# Solo Debug
	print("hitpoints: ", hitpoints)

## Metodos Custom
func aleatorizar_velocidad() -> float:
	randomize()
	return rand_range(0.5,2.1)

func recibir_danio(danio: float) -> void:
	hitpoints -= danio
	audio_impacto.play()
	animacion.play("impacto")
	if hitpoints <= 0.0:
		destruir()

func destruir() -> void:
	$CollisionShape2D.set_deferred("disable", true)
	Eventos.emit_signal("meteorito_destruido", global_position)
	queue_free()
