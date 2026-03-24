class_name InterceptState extends EnemyState


@export var speed : float = 200.0
@export var aceleration : float = 50
@export var turn_speed : float = 1.25



var max_bank_angle : float = 35.0
var bank_speed : float = 4.0
var current_bank : float = 0.0

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var player_offset : Vector3
var offset_distance : int = randi_range(50,65)

var los : Area3D
var obstacle_detectors: Array[RayCast3D]
var model:Node3D
@warning_ignore("shadowed_variable")
static func intercept_state_from(owner : BaseEnemy,model: Node3D,los:Area3D,detectors : Array[RayCast3D])-> EnemyState:
	var intercept_state : InterceptState= new()
	intercept_state.enemy = owner
	intercept_state.model = model
	intercept_state.los = los
	intercept_state.player = GameState.player
	intercept_state.obstacle_detectors = detectors
	
	return intercept_state

const MIN_ALTITUDE := 250.0
const ALTITUDE_FORCE := 100

func enter() -> void:
	los.body_entered.connect(on_los_body_entered)
	velocity_vec = enemy.velocity
	heading = - enemy.global_basis.z
	

	var basis := enemy.global_transform.basis
	var right := basis.x
	var up := basis.y
	var offset_dirs := [
	
	(right + up).normalized(),

	(-right + up).normalized(),

]	
	player_offset = offset_dirs.pick_random() * offset_distance
const AVOID_FORCE : float =20
const RAY_CAST_FRAME :int  = 15

var cached_avoid : Vector3 = Vector3.ZERO
func physics_update(delta: float) -> void:
	
	var player_forward :Vector3= -player.global_transform.basis.z
	
	var target :Vector3= player.global_position + player_offset + player_forward * 50
	target.y = clamp(target.y,250,100000)
	var desired_direction : Vector3= (target - enemy.global_position).normalized()

	if Engine.get_physics_frames() % RAY_CAST_FRAME ==0:
		cached_avoid = get_avoidance().normalized()
	var new_dir :Vector3= (desired_direction + (cached_avoid * AVOID_FORCE)).normalized()
	
	var old_heading :Vector3 = heading
	heading = heading.slerp(new_dir, turn_speed * delta).normalized()
	velocity_vec = velocity_vec.move_toward(heading * speed, aceleration * delta)
	if enemy.global_position.y < MIN_ALTITUDE:
			velocity_vec.y += ALTITUDE_FORCE * delta
	enemy.velocity = velocity_vec
	enemy.look_at(enemy.global_position + heading, Vector3.UP)
	var right :Vector3= enemy.global_transform.basis.x
	var heading_change :Vector3= heading - old_heading
	var turn_amount :float = clamp(right.dot(heading_change) * 10.0, -1.0, 1.0)

	var target_bank : float= turn_amount * max_bank_angle
	current_bank = lerp(current_bank, target_bank, bank_speed * delta)
	model.rotation_degrees.z = current_bank
func get_avoidance() -> Vector3:
	var avoid := Vector3.ZERO
	
	for ray in obstacle_detectors:
		ray.enabled = true
		ray.force_raycast_update()
		if ray.is_colliding():
			avoid += ray.get_collision_normal()
		ray.enabled = false
	return avoid
	
	




func start_lock_on() -> void:
	if AttackState.num_of_attacking_planes < AttackState.MAX_ATTACKING_PLANES:
		Transitioned.emit(self,EnemyPlane.STATES.ATTACK)
	#lock_on_timer.start()


func on_los_body_entered(body: Node3D)->void:
	if body is PlayerTank:
		start_lock_on()
#
#
#
#func _notification(what: int) -> void:
	#if what == NOTIFICATION_PREDELETE:
		#print("bye bye1")



	#los.body_entered.disconnect(on_los_body_entered)
	#enemy = null
	#model = null
	#los = null
#
	#obstacle_detectors = []
	
