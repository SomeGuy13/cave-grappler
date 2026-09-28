extends CharacterBody2D

enum State {
	IDLE,
	CHASING
}

@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea

var state = State.IDLE
var target = null
var speed = 500
var acceleration = 1000

func _process(delta: float) -> void:
	if state == State.IDLE:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if state == State.CHASING && target != null:
		move_to_position(target.position, delta)
	
	move_and_slide()

func move_to_position(point: Vector2, delta: float):
		var direction = global_position.direction_to(point).normalized()
		var desired_velocity = direction * speed
		
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

func die():
	queue_free()

func _on_detecion_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target = area.get_parent()
		state = State.CHASING
		velocity = Vector2.ZERO

func _on_detection_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		target = null
		state = State.IDLE
		velocity = Vector2.ZERO
