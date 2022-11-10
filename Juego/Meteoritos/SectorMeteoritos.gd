class_name SectorMeteoritos
extends Node2D

## Atributos Export
export var cantidad_meteoritos: int = 10
export var intervalo_spawn:float = 1.2

## Atributos
var spawners:Array

## Atributos Onready
onready var timer:Timer = $SpawnTimer




## Constructor
func crear(_pos: Vector2, meteoritos: int) -> void:
	global_position = _pos
	cantidad_meteoritos = meteoritos
#	print("en la funcion crear(_pos,meteoritos) del sectorMeteoritos, la global_position esta en ", global_position, " que deberia ser igual a la position, q vale ", position, " y por las dudas leo el parametro pos ", _pos)


## Metodos
func _ready() -> void:
	timer.wait_time = intervalo_spawn
	almacenar_spawners()
	conectar_seniales_detectores()
	
## Metodos Custom
func conectar_seniales_detectores() -> void:
	for detector in $DetectorFueraZona.get_children():
		detector.connect("body_entered", self, "_on_Detector_body_entered")

func almacenar_spawners() ->void:
	for spawner in $Spawners.get_children():
		spawners.append(spawner)

func spawner_aleatorio() -> int:
	randomize()
	return randi() % spawners.size()

## Señales Internas
func _on_SpawnTimer_timeout() -> void:
	if cantidad_meteoritos == 0:
		timer.stop()
		return
	spawners[spawner_aleatorio()].spawnear_meteorito()
	cantidad_meteoritos -= 1

func _on_Detector_body_entered(body: Node) -> void:
	body.set_esta_en_sector(false)
