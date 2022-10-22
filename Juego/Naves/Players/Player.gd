class_name Player
extends RigidBody2D

## Enums
enum ESTADO{SPAWN, VIVO, INVENCIBLE, MUERTO}

## Atributos Export
export var potencia_motor:int = 20
export var potencia_rotacion:int = 280
export var estela_maxima:int = 150
export var hitpoints:float = 15.0

## Atributos
var estado_actual:int = ESTADO.SPAWN
var estado_vivo:int = ESTADO.VIVO
var estado_muerto:int = ESTADO.MUERTO
var estado_cheat:int = ESTADO.INVENCIBLE
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0

## Atributos Onready
onready var colisionador:CollisionShape2D = $CollisionShape2D
onready var canion:Canion = $Canion
onready var laser:RayoLaser = $LaserBeam2D
onready var estela:Estelar = $Estela/Trail2D
onready var audio_motor:AudioStreamPlayer2D = $motor_sfx
onready var audio_danio:AudioStreamPlayer = $danio_sfx
onready var escudo:Escudo = $Escudo

## Metodos
func _ready() -> void:
	controlador_estados(estado_actual)



func _unhandled_input(event: InputEvent) -> void:
	if not esta_input_activo():
		return

	# Control Escudo
	if event.is_action_pressed("activar_escudo") and not escudo.get_esta_activado():
		escudo.activar()

	#Disparo Laser
	if event.is_action_pressed("disparo_secundario"):
		laser.set_is_casting(true)
	if event.is_action_released("disparo_secundario"):
		laser.set_is_casting(false)
	
	#Estela y audio motor
	if event.is_action_pressed("mover_adelante"):
		estela.set_max_points(estela_maxima)
		estela.set_emitting(true)
		audio_motor.sonido_on()
		
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
		audio_motor.sonido_on()
	
	if event.is_action_released("mover_adelante")	or event.is_action_released("mover_atras"):
			audio_motor.sonido_off()
		
func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	apply_central_impulse(empuje.rotated(rotation))
	apply_torque_impulse(dir_rotacion*potencia_rotacion)


func _process(_delta: float) -> void:
	player_input()
	
##Metodos Custom
func controlador_estados(nuevo_estado:int) -> void:
	match nuevo_estado:
		ESTADO.SPAWN:
			colisionador.set_deferred("disable", true)
			canion.set_puede_disparar(false)
			print("aca estoy perro")
		ESTADO.VIVO:
			colisionador.set_deferred("disable", false)
			canion.set_puede_disparar(true)
			print("muevo la cola")
		ESTADO.INVENCIBLE:
			colisionador.set_deferred("disable", true)
		ESTADO.MUERTO:
			colisionador.set_deferred("disable", false)
			canion.set_puede_disparar(false)
			Eventos.emit_signal("nave_destruida", self, global_position,3)
			print("tire la pata")
			queue_free()
		_:
			print("error de estado")
	estado_actual = nuevo_estado
	
func esta_input_activo() -> bool:
	if estado_actual  in [ESTADO.MUERTO, ESTADO.VIVO]:
		return true
	return false	

func player_input() -> void:
	if not esta_input_activo():
		return
		
	empuje = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		empuje = Vector2(potencia_motor,0)
		
	elif Input.is_action_pressed("mover_atras"):
		empuje = Vector2(-potencia_motor,0)
	
	dir_rotacion=0
	if Input.is_action_pressed("giro_antihorario"):
		dir_rotacion -=1
	elif Input.is_action_pressed("giro_horario"):
		dir_rotacion += 1
		
	if Input.is_action_pressed("disparo_principal"):
		canion.set_esta_disparando(true)
	
	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)

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


func _on_body_entered(body: Node) -> void:
	if body is Meteorito:
		body.destruir()
		destruir()


