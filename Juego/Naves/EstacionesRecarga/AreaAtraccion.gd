extends Area2D

## Señales Externas ############################################################
func _on_body_entered(body: Node) -> void:
	body.set_gravity_scale(0.1)

func _on_body_exited(body: Node) -> void:
	body.set_gravity_scale(0.0)
