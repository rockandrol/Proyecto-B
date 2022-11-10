class_name SectorPeligro
extends Area2D

## Atributos Export
export(String, "vacio", "Meteorito", "Enemigo") var tipo_peligro
export var numero_peligros:int = 10

## Atributos Onready
onready var centro:Position2D = $CentroSector


## Señales
func _on_body_entered(_body: Node) -> void:
	
	$CollisionShape2D.set_deferred("disable", true)
	yield(get_tree().create_timer(0.1), "timeout")
	enviar_senial()

func enviar_senial() -> void:
	Eventos.emit_signal(
		"nave_en_sector_peligro",
		centro.global_position,
		tipo_peligro,
		numero_peligros
	)
#	print("el CentroSector del sectorPeligro esta en ", centro.global_position)
	
	queue_free()
