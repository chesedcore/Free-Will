class_name HomingMissle extends CharacterBody3D

@export var target_node : PhysicsBody3D
@export var Max_speed : float = 250
@export var turn_speed : float = 6.0
var locked_on : bool = true
var lock_off_dist : float = 50
var lifespan : float = 10

func _physics_process(delta: float) -> void:
	if not target_node:
		return
	if locked_on:
		var to_target : Vector3 = (target_node.global_position - global_position).normalized()
		var forward : Vector3 = -global_transform.basis.z
		var rotate_amount : Vector3 = forward.cross(to_target)
		rotate_object_local(Vector3.UP, rotate_amount.y * turn_speed * delta)
		rotate_object_local(Vector3.RIGHT, rotate_amount.x * turn_speed * delta)
		if global_position.distance_to(target_node.global_position)<lock_off_dist:
			locked_on = false
	velocity = -global_transform.basis.z * Max_speed
	move_and_slide()
	if lifespan>0 :
		lifespan-= delta
	else:
		call_deferred("queue_free")


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		var particles: Node3D = \
			preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()
		print("hit")
		body.add_child(particles)
		
		call_deferred("queue_free")
