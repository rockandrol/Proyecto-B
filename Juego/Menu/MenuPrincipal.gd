##MenuPrincipal
extends Node

func _ready() -> void:
	MusicaJuego.play_musica(MusicaJuego.get_lista_musica().menu_principal)





func _on_Button_pressed() -> void:
	MusicaJuego.play_boton()
	get_tree().change_scene("res://Juego/Niveles/NivelBase.tscn")
