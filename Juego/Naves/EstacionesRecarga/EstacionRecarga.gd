class_name EstacionRecarga
extends Node2D

## Atributos Export
export var energia:float = 6.0
export var radio_energia_entregada:float = 0.05

## Atributos 
var nave_player:Player = null
var player_zona:bool = false

## Atributos Onready
onready var anim_esta:AnimationPlayer = $AnimationPlayer
onready var carga_sfx:AudioStreamPlayer = $carga
onready var vacio_sfx:AudioStreamPlayer = $vacio

## Metodos
func _unhandled_input(event: InputEvent) -> void:
	if not puede_recargar(event):
		return
	controlar_energia()
	
	if event.is_action("recargar_escudo"):
		nave_player.get_escudo().controlar_energia(radio_energia_entregada)
	elif event.is_action("recargar_rayolaser"):
		nave_player.get_laser().controlar_energia(radio_energia_entregada)

## Metodos Custom
func puede_recargar(event: InputEvent) -> bool:
	var hay_input = event.is_action("recargar_escudo") or event.is_action("recargar_rayolaser")
	if hay_input and player_zona and energia > 0.0:
		if !carga_sfx.playing:
			carga_sfx.play()
		return true
	return false

func controlar_energia() -> void:
	energia -= radio_energia_entregada
	if energia <= 0.0:
		$vacio.play()
	print("Energia Estacion: ", energia)

## Señales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()

func _on_AreaRecarga_body_entered(body: Node) -> void:
	if body is Player:
		nave_player = body	
		player_zona = true
	body.set_gravity_scale(0.1)

func _on_AreaRecarga_body_exited(body: Node) -> void:
	body.set_gravity_scale(0.0)
	player_zona = false
	
