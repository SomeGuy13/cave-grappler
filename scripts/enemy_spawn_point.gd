extends Node2D

@onready var sprite = $AnimatedSprite2D

var occupied = false

func spawn_enemy(scene: String):
	var enemy = load(scene)
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = position
	sprite.visible = true
	sprite.play("opening")
	await sprite.animation_finished
	get_parent().add_child(enemy_instance)
	occupied = true
	sprite.play("closing")
	await sprite.animation_finished
	sprite.visible = false

func _on_area_exited(area: Area2D) -> void:
	occupied = false
