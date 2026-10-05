extends Node2D

@onready var animation_player = $AnimationPlayer
var open = false

func open_door():
	if !open:
		animation_player.play("open")
		open = true

func close_door():
	if open:
		animation_player.play("close")
		open = false
