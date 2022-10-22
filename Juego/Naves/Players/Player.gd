class_name Player
extends "res://Juego/Naves/NaveBase.gd"

## Atributos Export
export var potencia_motor:int = 18
export var potencia_rotacion:int = 260
export var estela_maxima:int = 150

## Atributos
var empuje:Vector2 = Vector2.ZERO
var dir_rotacion:int = 0

## Atributos Onready
onready var estela:Estelar = $Estela/Trail2D
onready var audio_motor:AudioStreamPlayer2D = $motor_sfx
onready var laser:RayoLaser = $LaserBeam2D setget ,get_laser
onready var escudo:Escudo = $Escudo setget ,get_escudo

## Setters y Getters
func get_laser() -> RayoLaser:
	return laser

func get_escudo() -> Escudo:
	return escudo
