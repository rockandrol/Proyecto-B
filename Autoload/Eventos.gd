##Eventos
extends Node

# warning-ignore:unused_signal
signal nivel_iniciado()
# warning-ignore:unused_signal
signal disparo(proyectil)
# warning-ignore:unused_signal
signal detector_zona_recarga(entrando)
# warning-ignore:unused_signal
signal nave_destruida(nave, posicion, explosiones)
# warning-ignore:unused_signal
signal spawn_meteorito(posicion, direccion, tamanio)
# warning-ignore:unused_signal
signal meteorito_destruido(posicion)
# warning-ignore:unused_signal
signal nave_en_sector_peligro(centro_camara, tipo_peligro, numero_peligros)
# warning-ignore:unused_signal
signal base_destruida(base, posicion, explosiones)
# warning-ignore:unused_signal
signal spawn_orbital(orbital)
# warning-ignore:unused_signal
signal nivel_terminado()
# warning-ignore:unused_signal
signal nivel_completado()
# warning-ignore:unused_signal
signal explotar_misil(posicion,explosiones)
# warning-ignore:unused_signal
signal mostrar_cursor()
# warning-ignore:unused_signal
signal ocultar_cursor()



################################################################################
#HUD
################################################################################
# warning-ignore:unused_signal
signal cambio_numero_meteoritos(numero)
# warning-ignore:unused_signal
signal actualizar_tiempo(tiempo_restante)
# warning-ignore:unused_signal
signal cambio_energia_laser(energia_max, energia_actual)
# warning-ignore:unused_signal
signal ocultar_energia_laser()
# warning-ignore:unused_signal
signal cambio_energia_escudo(energia_max, energia_actual)
# warning-ignore:unused_signal
signal cambio_energia_turbo(energia_max, energia_actual)
# warning-ignore:unused_signal
signal ocultar_energia_turbo()
# warning-ignore:unused_signal
signal ocultar_energia_escudo()
# warning-ignore:unused_signal
signal minimpa_objeto_creado()
# warning-ignore:unused_signal
signal minimapa_objeto_destruido(objeto)
