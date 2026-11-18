extends Control

func _process(delta: float) -> void:
	if Input.is_action_pressed("Pause"):
		visible = true
		get_tree().paused = true

func _on_menu_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_resume_button_down() -> void:
	get_tree().paused = false
	visible = false
