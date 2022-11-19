class_name Player
extends NaveBase

## Atributos Export ############################################################
export var potencia_motor:float = 20
export var potencia_rotacion:int = 280
export var estela_maxima:int = 150
export var turbo:int = 3
export var radio_desgaste_turbo:float = -0.1
export var energia:float = 50.0 


## Atributos ###################################################################
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0
var energia_original:float 
var turbo_activo:bool = false 


## Atributos Onready ###########################################################
onready var laser:RayoLaser = $LaserBeam2D setget ,get_laser
onready var estela:Estelar = $Estela/Trail2D
onready var audio_motor:AudioStreamPlayer2D = $motor_sfx
onready var escudo:Escudo = $Escudo setget ,get_escudo
onready var animacion:AnimationPlayer = $AnimationPlayer


## Setters y Getters ###########################################################
func get_laser() -> RayoLaser:
	return laser

func get_escudo() -> Escudo:
	return escudo



## Metodos #####################################################################
func _ready() -> void:
	DatosJuego.set_player_actual(self)
	energia_original = energia


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
	
	if event.is_action_pressed("mover_adelante") and event.is_action_pressed("turbo"):
		estela.set_max_points(estela_maxima)
		estela.set_emitting(true)
		
	
	elif event.is_action_pressed("mover_atras"):
		estela.set_max_points(0)
		audio_motor.sonido_on()
	if event.is_action_released("mover_adelante")	or event.is_action_released("mover_atras"):
		audio_motor.sonido_off()

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	apply_central_impulse(empuje.rotated(rotation))
	apply_torque_impulse(dir_rotacion*potencia_rotacion)

func _process(_delta: float) -> void:
	controlar_energia(radio_desgaste_turbo)
	player_input()


## Metodos Custom ##############################################################
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
		audio_motor.sonido_on()
	elif Input.is_action_pressed("mover_atras"):
		empuje = Vector2(-potencia_motor,0)
		audio_motor.sonido_on()

	if Input.is_action_pressed("turbo") and Input.is_action_pressed("mover_adelante"):
		activar_turbo()
		
	elif Input.is_action_just_released("mover_adelante") or Input.is_action_just_released("turbo"):
		turbo_activo = false
		desactivar_turbo()

	dir_rotacion=0
	if Input.is_action_pressed("giro_antihorario"):
		dir_rotacion -=1
	elif Input.is_action_pressed("giro_horario"):
		dir_rotacion += 1

	if Input.is_action_pressed("disparo_principal"):
		canion.set_esta_disparando(true)

	if Input.is_action_just_released("disparo_principal"):
		canion.set_esta_disparando(false)

func desactivar_controles() -> void:
	controlador_estados(ESTADO.SPAWN)
	empuje = Vector2.ZERO
	audio_motor.sonido_off()
	laser.set_is_casting(false)

func controlar_energia(consumo:float) -> void:
	if turbo_activo:
		energia += consumo
		if energia > energia_original:
			turbo = 3
		elif energia <= 1:
			turbo_activo = false
			turbo = 1
			Eventos.emit_signal("ocultar_energia_turbo")
			desactivar_turbo()
			return
		Eventos.emit_signal("cambio_energia_turbo",energia_original,energia)

func activar_turbo() -> void:
	empuje = Vector2(potencia_motor * turbo , 0)
	turbo_activo = true
	if energia > 1:
		estela.modulate = Color(22,67,123,0.01)
		audio_motor.sonido_turbo_on()
	else:
		desactivar_turbo()

func desactivar_turbo() -> void:
	Eventos.emit_signal("ocultar_energia_turbo")
	estela.modulate = Color(1,0.68,1,0.45)
	yield(get_tree().create_timer(0.1), "timeout")
	estela.modulate = Color(1,0.68,0,0.37)	


