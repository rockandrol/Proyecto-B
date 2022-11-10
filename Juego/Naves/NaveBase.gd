class_name NaveBase
extends RigidBody2D

## Enums
enum ESTADO{SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos Export
export var hitpoints:float = 15.0
export var numExplosiones:int = 3

## Atributos
var estado_actual:int = ESTADO.SPAWN
var estado_vivo:int = ESTADO.VIVO
var estado_muerto:int = ESTADO.MUERTO
var estado_cheat:int = ESTADO.INVENCIBLE


## Atributos Onready
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var audio_danio:AudioStreamPlayer = $danio_sfx
onready var canion:Canion = $Canion
onready var barra_salud:ProgressBar = $SaludBar

## Metodos
func _ready() -> void:
	barra_salud.set_valores(hitpoints)
	controlador_estados(estado_actual)
	

##Metodos Custom
func controlador_estados(nuevo_estado:int) -> void:
	match nuevo_estado:
		ESTADO.SPAWN:
			colisionador.set_deferred("disable", true)
			canion.set_puede_disparar(false)
		ESTADO.VIVO:
			colisionador.set_deferred("disable", false)
			canion.set_puede_disparar(true)
		ESTADO.INVENCIBLE:
			colisionador.set_deferred("disable", true)
		ESTADO.MUERTO:
			colisionador.set_deferred("disable", false)
			canion.set_puede_disparar(false)
			Eventos.emit_signal("nave_destruida", self, global_position,numExplosiones)
			queue_free()
		_:
			print("error de estado")
	estado_actual = nuevo_estado
	


func destruir() -> void:
	controlador_estados(ESTADO.MUERTO)



##Señales internas
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn" :
		controlador_estados(ESTADO.VIVO)
		
func recibir_danio(danio: float) -> void:
	hitpoints -= danio
	audio_danio.play()
	if hitpoints <= 0.0:
		destruir()
	barra_salud.controlar_barra(hitpoints,true)
	


func _on_body_entered(body: Node) -> void:
	if body is Meteorito:
		body.destruir()
		destruir()


