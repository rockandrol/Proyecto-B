##MenuPrincipal
extends Node
export(String,FILE,"*.tscn") var prox_nivel = ""

func _ready() -> void:
	MusicaJuego.play_musica(MusicaJuego.get_lista_musica().menu_principal)
	OS.set_window_fullscreen(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Button_pressed() -> void:
	MusicaJuego.play_boton()
# warning-ignore:return_value_discarded
	get_tree().change_scene(prox_nivel)


func _on_Button2_pressed() -> void:
	get_tree().quit()
