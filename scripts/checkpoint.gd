extends Node2D

@export var checkpoint_id = 0
@export var camera_location = Vector2(0, 0)
@export var camera = Camera2D
@export var camera_move_time = 0.75

func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area)
	var tween = create_tween()
	tween.tween_property(camera, "position", camera_location, camera_move_time)
	camera.position = camera_location
