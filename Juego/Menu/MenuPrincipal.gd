##MenuPrincipal
extends Node

## Atributos Export ############################################################
export(String,FILE,"*.tscn") var prox_nivel = ""


## Metodos  ####################################################################
func _ready() -> void:
	MusicaJuego.play_musica(MusicaJuego.get_lista_musica().menu_principal)
	OS.set_window_fullscreen(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## Señales Externas ############################################################
func _on_Button_pressed() -> void:
	MusicaJuego.play_boton()
# warning-ignore:return_value_discarded
	get_tree().change_scene(prox_nivel)

func _on_Button2_pressed() -> void:
	get_tree().quit()
