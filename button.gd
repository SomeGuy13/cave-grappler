extends Node2D

@export var door: Node2D
@onready var sprite = $AnimatedSprite2D

func _on_area_entered(area: Area2D) -> void:
	door.open_door()
	sprite.play("closed")

func _on_area_exited(area: Area2D) -> void:
	sprite.play("open")
