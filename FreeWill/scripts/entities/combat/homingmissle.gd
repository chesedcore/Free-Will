class_name HomingMissle extends CharacterBody3D

const THREAT_INDICATOR = preload("res://scenes/entities/combat/threat_indicator.tscn")

@export var target_node : PhysicsBody3D
@export var Max_speed : float = 250
@export var turn_speed : float =10

@export var damage_value: float = 10.0
@export var impact_sound: AudioStream = preload("res://audio/sfx/explosion.ogg")
@export var spawn_sound: AudioStream = preload("res://audio/sfx/rocket_launch_2.ogg")

var locked_on : bool = true
var lock_off_dist : float = 25
var lifespan : float = 5
var threat_indicator : ThreatIndicator

func _process(delta: float) -> void:
	if global_position.y <= -10:
		call_deferred("queue_free")

func  _ready() -> void:
	AudioManager.play_sound_at(global_position, spawn_sound, 10.0)

	if target_node:
		threat_indicator = THREAT_INDICATOR.instantiate()
		threat_indicator.target_node = self
#		threat_indicator.is_dangerous = true
		target_node.add_child(threat_indicator)


func _physics_process(delta: float) -> void:
	if not target_node:
		return
	

	if locked_on:
		var distance : float = global_position.distance_to(target_node.global_position)
		var predict_time : float = min(distance/ velocity.length(),1)
		var predict_target : Vector3

		if target_node is CharacterBody3D :
			predict_target= target_node.global_position + target_node.velocity * predict_time
		elif target_node is RigidBody3D:
			predict_target= target_node.global_position + target_node.linear_velocity * predict_time

		var dir_to_predict : Vector3 = (predict_target - global_position).normalized()
		var forward : Vector3 = -global_transform.basis.z
		var new_dir :Vector3= forward.slerp(dir_to_predict, turn_speed * delta).normalized()

		look_at(global_position + new_dir, Vector3.UP)

		if distance<lock_off_dist:
			locked_on = false
			if threat_indicator:
				threat_indicator.target_node = null
		

	if lifespan > 0:
		lifespan -= delta
		velocity = -global_transform.basis.z * Max_speed
	else:
		if threat_indicator:
			threat_indicator.target_node = null
		locked_on = false
		velocity += get_gravity() *2 * delta
		
	move_and_slide()

	

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		var particles: Node3D = \
			preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()
		body.add_child(particles)
		body.damage(damage_value)

		AudioManager.play_sound_at(global_position, impact_sound, 15.0)

		call_deferred("queue_free")
