extends Control

@export var scene_on_play: PackedScene

func _on_button_pressed() -> void:
	AudioManager.poof.play()
	get_tree().change_scene_to_packed(scene_on_play)
