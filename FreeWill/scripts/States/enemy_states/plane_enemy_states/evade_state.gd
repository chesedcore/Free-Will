class_name EvadeState extends EnemyState

var speed : float = 200
var aceleration : float = 50
var turn_speed : float = 1.25
var evade_distance : float = 200
var evade_duration : float = 5

var forward_distance: float = 600

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var evade_offset : Vector3
var evade_target : Vector3
var cached_avoid : Vector3 = Vector3.ZERO

var max_bank_angle : float = 35.0
var bank_speed : float = 4.0
var current_bank : float = 0.0

const MIN_ALTITUDE := 250.0
const ALTITUDE_FORCE := 100


var model : Node3D
var obstacle_detectors: Array[RayCast3D]

@warning_ignore("shadowed_variable")
static func evade_state_from(owner : BaseEnemy,model:Node3D,detectors: Array[RayCast3D])-> EvadeState:
	var state : EvadeState= new()
	state.enemy = owner
	state.player = GameState.player
	state.model= model
	state.obstacle_detectors = detectors
	return state

func enter() -> void:
	velocity_vec = enemy.velocity
	heading = velocity_vec.normalized()

	var basis := enemy.global_transform.basis
	var right := basis.x

	var evade_dirs := [
		right,
		-right,
	]
	evade_offset = evade_dirs.pick_random() *evade_distance
	var forward := -enemy.global_transform.basis.z
	evade_target = enemy.global_position + evade_offset + forward * forward_distance


func get_avoidance() -> Vector3:
	var avoid := Vector3.ZERO

	for ray in obstacle_detectors:
		ray.enabled = true
		ray.force_raycast_update()
		if ray.is_colliding():
			avoid += ray.get_collision_normal()
		ray.enabled = false
	return avoid


#
#
#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#print("bye bye2")


const  AVOID_FORCE : float = 20

const RAY_CAST_FRAME :int  = 15

func physics_update(_delta: float) -> void:
	if enemy and player:
		if evade_duration >0 :
			evade_duration -= _delta
		else:
			Transitioned.emit(self,EnemyPlane.STATES.INTERCEPT)
		evade_target.y = clamp(evade_target.y,150,100000)
		var desired_direction := (evade_target - enemy.global_position).normalized()

		if Engine.get_physics_frames() % RAY_CAST_FRAME==0:
			cached_avoid = get_avoidance().normalized()
		var new_dir :Vector3= (desired_direction + (cached_avoid * AVOID_FORCE)).normalized()
		var old_heading :Vector3 = heading
		heading = heading.slerp(new_dir, turn_speed * _delta).normalized()
		velocity_vec = velocity_vec.move_toward(heading * speed, aceleration * _delta)
		if enemy.global_position.y < MIN_ALTITUDE:
			velocity_vec.y += ALTITUDE_FORCE * _delta
		enemy.velocity = velocity_vec
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		var right :Vector3= enemy.global_transform.basis.x
		var heading_change :Vector3= heading - old_heading
		var turn_amount :float = clamp(right.dot(heading_change) * 10.0, -1.0, 1.0)
		var target_bank : float= turn_amount * max_bank_angle
		current_bank = lerp(current_bank, target_bank, bank_speed * _delta)
		model.rotation_degrees.z = current_bank
