class_name HomingMissle extends CharacterBody3D

@export var target_node : PhysicsBody3D
var lifespan : float = 6
var heading : Vector3 = Vector3.FORWARD
var turn_speed : float = 10
@export var Max_speed : float = 250
@export var aceleration : float = 50
var velocity_vec :Vector3


func _ready() -> void:
	heading = -global_transform.basis.z

func _physics_process(delta: float) -> void:
	if not target_node:
		velocity = heading * Max_speed
	else:
		var target := target_node.global_position 
		var forward := -global_transform.basis.z
		
		var desired_direction := (target - global_position).normalized()
		
		heading = heading.slerp(desired_direction, turn_speed * delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * Max_speed, aceleration * delta)
		look_at(global_position + heading, Vector3.UP)
		velocity = velocity_vec
		move_and_slide()
		if lifespan >= 0:
			lifespan-= delta
		else:
			call_deferred("queue_free")
	
