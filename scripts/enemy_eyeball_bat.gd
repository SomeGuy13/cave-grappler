extends CharacterBody2D

@export var knockback_speed = 50
@export var knockback_friction = 500
@export var knockback_stop_speed = 20
@export var max_health = 100
@export var health: float

@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $EnemyDetectionArea

const DEAD_SCENE = preload("res://scenes/dead_eyeball_bat.tscn")

var state = State.IDLE
var target = null
var speed = 500
var acceleration = 1000
var knockback_velocity: Vector2 = Vector2.ZERO

enum State {
	IDLE,
	CHASING,
	DEAD,
	HURT
}

func _ready() -> void:
	health = max_health

func _process(delta: float) -> void:
	if state == State.IDLE:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if state == State.CHASING && target != null:
		move_to_position(target.position, delta)
	
	velocity = velocity + knockback_velocity
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	
	if knockback_velocity.length() < knockback_stop_speed:
		knockback_velocity = Vector2.ZERO
	
	move_and_slide()

func move_to_position(point: Vector2, delta: float):
		var direction = global_position.direction_to(point).normalized()
		var desired_velocity = direction * speed
		
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

func die():
	state = State.DEAD
	var dead_eyeball_bat = DEAD_SCENE
	var dead_eyeball_bat_instance = dead_eyeball_bat.instantiate()
	dead_eyeball_bat_instance.position = position
	get_parent().add_child(dead_eyeball_bat_instance)
	queue_free()

func apply_knockback(hit_position: Vector2, strength: float):
	var knockback_direction = hit_position.direction_to(global_position)
	
	knockback_velocity = knockback_direction * strength

func take_damage(damage) -> void:
	if health - damage <= 0:
		die()
		return
	
	health -= damage
	
	var prior_state = state
	state = State.HURT
	sprite.stop()
	sprite.play("hurt")
	await sprite.animation_finished
	state = prior_state

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

func _on_attack_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer() == 32 && state != State.HURT:
		var player = area.get_parent()
		area.get_parent().die()
