tool
extends ParallaxBackground

## Atributos Export ############################################################
export var color_fondo: = Color.black


## Metodos #####################################################################
func _ready() -> void:
	$ColorRect.color = color_fondo

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		$ColorRect.color = color_fondo
