class_name ReleMasa
extends Node2D

## Metodos #####################################################################
func _ready() -> void:
	Eventos.emit_signal("minimpa_objeto_creado")


## Metodo Custom ###############################################################
func atraer_player(body: Node) -> void:
	$Tween.interpolate_property(
		body,
		"global_position",
		body.global_position,
		global_position,
		1.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	$Tween.start()


## Señales Internas ############################################################
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "spawn":
		$AnimationPlayer.play("activada")

func _on_DetectorPlayer_body_entered(body: Node) -> void:
	$DetectorPlayer/CollisionShape2D.set_deferred("disable", true)
	$AnimationPlayer.play("super_activada")
	body.desactivar_controles()
	atraer_player(body)

func _on_Tween_tween_all_completed() -> void:
	Eventos.emit_signal("nivel_completado")
