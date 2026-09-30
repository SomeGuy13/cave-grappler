extends Node2D

var occupied = false

func _process(delta: float) -> void:
	#print(name, " is occupied: ", occupied)
	pass

func spawn_enemy(scene: String):
	var enemy = load(scene)
	var enemy_instance = enemy.instantiate()
	enemy_instance.position = position
	get_parent().add_child(enemy_instance)
	occupied = true

func _on_area_exited(area: Area2D) -> void:
	occupied = false
