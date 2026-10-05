extends Node2D

@export var enemies_to_spawn = 5
@export var spawn_frequency_min = 2.0
@export var spawn_frequency_max = 5.0
@export var enemy_scenes = [""]

var spawners = []
var spawn_time

signal spawning_started()
signal spawning_ended()

func _ready() -> void:
	for child in get_children():
		spawners.append(child)
	spawn_time = randf_range(spawn_frequency_min, spawn_frequency_max)

func _process(delta: float) -> void:
	if enemies_to_spawn > 0:
		if spawn_time <= 0:
			var spawner = spawners[randi_range(0, spawners.size() - 1)]
			if spawner.occupied == false:
				var enemy_scene = enemy_scenes[randi_range(0, enemy_scenes.size() - 1)]
				spawner.spawn_enemy(enemy_scene)
				enemies_to_spawn -= 1
			spawn_time = randf_range(spawn_frequency_min, spawn_frequency_max)
	
	spawn_time -= delta
