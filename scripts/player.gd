extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var space_state = get_world_2d().direct_space_state
@onready var rope = $Rope
@onready var attack_box = $AttackBox
@onready var attack_shape = $AttackBox/CollisionShape2D
@onready var detection_shape = $CollisionShape2D

var grappling = false
var attacking = false
var dead = false

var grapple_position = Vector2.ZERO
var ray_hit_position = null

const SPEED = 350.0
const JUMP_VELOCITY = -500.0

@export var max_speed = 800
@export var acceleration = 10000
@export var stopping_distance = 0
@export var gravity_multiplyer = 2.5
@export var death_wait_time = 1
@export var knockback_strength = 150

func _physics_process(delta: float) -> void:
	if !dead:
		handle_jump()
		handle_movement()
		handle_attack()
		handle_animations()
		
		if Input.is_action_pressed("Grapple") and !grappling:
			grappling = true
			ray_hit_position = cast_ray()
		
			print(ray_hit_position)
		
		if Input.is_action_just_released("Grapple"):
			grappling = false
		
		handle_grapple(delta)
	
	apply_gravity(delta)
	
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
	grapple_position = ray_hit_position
	
	if grappling and grapple_position != null:
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

func die():
	dead = true
	rotation = -90
	sprite.stop()
	velocity = Vector2.ZERO
	rope.visible = false
	grappling = false
	attack_shape.disabled = true
	await get_tree().create_timer(death_wait_time).timeout
	if get_tree() != null:
		get_tree().reload_current_scene()

func _on_detection_area_entered(area: Area2D) -> void:
	if area is Area2D:
		if area.get_collision_layer_value(5): # Spikes Layer
			die()

func _on_attack_box_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		var enemy = area.get_parent()
		enemy.take_damage(50)
		
		if grappling:
			enemy.apply_knockback(position, knockback_strength + velocity.length() / 100)
		else:
			enemy.apply_knockback(position, knockback_strength)
