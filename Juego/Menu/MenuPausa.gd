class_name Pausa
extends Control



func _ready() -> void:
	visible = false
	get_tree().paused = false
	
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa"):
		visible = not visible
		get_tree().paused = not get_tree().paused
		Eventos.emit_signal("mostrar_cursor")
		
		

func _on_Continuar_pressed() -> void:
	visible = false
	get_tree().paused = false
	Eventos.emit_signal("ocultar_cursor")

func _on_MenuPrincipal_pressed() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Juego/Menu/MenuPrincipal.tscn")

func _on_Salir_pressed() -> void:
	get_tree().quit()
