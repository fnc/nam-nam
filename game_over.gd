extends Node2D

@onready var boton_reiniciar = $Button
@export var escena_inicio: PackedScene = preload("res://game.tscn")  # Cambiá por tu escena inicial

func _ready():
	boton_reiniciar.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	AudioManager.positive_reaction.play()
	Global.score = 0  # Reiniciamos el puntaje
	get_tree().change_scene_to_file("res://game.tscn")
