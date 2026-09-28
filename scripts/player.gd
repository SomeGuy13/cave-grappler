extends CharacterBody2D

const SPEED = 350.0
const JUMP_VELOCITY = -900.0

var max_speed = 800
var acceleration = 10000
var stopping_distance = 8

var grappling = false
var attacking = false

@export var gravity_multiplyer = 2.5

@onready var sprite = $AnimatedSprite2D
@onready var space_state = get_world_2d().direct_space_state
@onready var rope = $Rope
@onready var attack_box = $AttackBox
@onready var attack_shape = $AttackBox/CollisionShape2D

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement()
	handle_attack()
	handle_grapple(delta)
	handle_animations()
	
	move_and_slide()

func apply_gravity(delta: float):
	if not is_on_floor() and !grappling:
		velocity += get_gravity() * delta * gravity_multiplyer

func handle_jump():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement():
	if !grappling:
		var direction := Input.get_axis("Left", "Right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if direction != 0:
			sprite.scale.x = direction
			attack_box.scale.x = direction

func handle_attack():
	if Input.is_action_pressed("Attack"):
		attacking = true
		attack_shape.disabled = false
		sprite.stop()
		sprite.play("attacking")
		await sprite.animation_finished
		attacking = false
		attack_shape.disabled = true

func handle_grapple(delta: float):
	var grapple_position = Vector2.ZERO
	var ray_hit_position = cast_ray()

	if Input.is_action_pressed("Grapple") and !grappling:
		grappling = true
	
	if Input.is_action_just_released("Grapple"):
		grappling = false

	if ray_hit_position == null:
		grappling = false

	if grappling:
		if ray_hit_position != null:
			grapple_position = ray_hit_position
		
		accelerate_towards_point(grapple_position, delta)
		rope.visible = true
		rope.set_point_position(1, rope.to_local(grapple_position))
		
	else:
		grappling = false
		rope.visible = false
		grapple_position = to_local(Vector2.ZERO)

func cast_ray(): 
		var origin = global_position
		var mouse_position = get_global_mouse_position()
		
		var query = PhysicsRayQueryParameters2D.create(origin, mouse_position)
		var result = space_state.intersect_ray(query)
		if !result.is_empty():
			return result.position
		return null

func accelerate_towards_point(point: Vector2, delta: float):
	var distance = global_position.distance_to(point)
	
	if distance > stopping_distance:
		var direction = global_position.direction_to(point).normalized()
		var desired_velocity = direction * max_speed
		
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)

func handle_animations():
	if attacking:
		sprite.play("attacking")
	elif !is_on_floor():
		sprite.play("jumping")
	elif abs(velocity.x) > 0.1 and is_on_floor():
		sprite.play("walking")
	elif is_on_floor():
		sprite.play("idle")

func _on_detection_area_entered(area: Area2D) -> void:
	if area is Area2D:
		if area.get_collision_layer_value(2): # Spikes Layer
			get_tree().reload_current_scene()

func _on_attack_box_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		print("Hit enemy!")
		area.get_parent().die()
