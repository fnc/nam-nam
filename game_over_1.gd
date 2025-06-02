extends Node2D

@onready var label = $Label
@export var next_scene: PackedScene
@export var creditos_scene: PackedScene = preload("res://gameOver.tscn")  # Ajustá la ruta

func _ready():
	label.text = str(Global.score)  # Suponiendo que usás un singleton Global para compartir datos


func _on_button_pressed() -> void:
	AudioManager.positive_reaction.play()
	get_tree().change_scene_to_packed(creditos_scene)
