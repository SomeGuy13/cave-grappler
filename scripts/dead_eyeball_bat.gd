extends Node2D

@export var decay_delay = 1

func _ready():
	await get_tree().create_timer(decay_delay).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
