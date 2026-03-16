class_name ShipWanderState extends EnemyState


var obstacle_detectors: Array[RayCast3D]

var move_speed : float = 50
var turn_speed : float = 1.05

var heading : Vector3 = Vector3.FORWARD
var move_direction : Vector3
var wander_time : float
var aceleration : float = 15

func randomize_wander()->void:
	var forward := -enemy.global_transform.basis.z
	
	var random_offset := Vector3(
		randf_range(-0.6, 0.6),
		0,
		randf_range(0.2, 1.0) # always forward
	)
	
	move_direction = (forward + random_offset).normalized()
	wander_time = randf_range(5,7)


var los : Area3D


func enter()->void:
	los.body_entered.connect(on_los_body_entered)
	randomize_wander()


static  func wander_state_from(owner : BaseEnemy,detectors: Array[RayCast3D],los : Area3D)->State:
	var state : ShipWanderState = new()
	state.enemy  = owner
	state.obstacle_detectors = detectors
	state.los = los
	return state
	
	
func update(_delta : float)->void:
	if wander_time>0:
		wander_time -= _delta
	else:
		randomize_wander()

const  AVOID_FORCE : float =20

func physics_update(_delta :float)->void:
	if enemy:
		var forward := -enemy.global_transform.basis.z
		var avoid := get_avoidance()
		var desired_dir := (move_direction + avoid * AVOID_FORCE)
		heading = heading.slerp(desired_dir, turn_speed * _delta).normalized()
	
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = enemy.velocity.move_toward(heading * move_speed, aceleration * _delta)
		
		
func get_avoidance() -> Vector3:
	var avoid := Vector3.ZERO
	
	for ray in obstacle_detectors:
		if ray.is_colliding():
			avoid += ray.get_collision_normal()
	
	return avoid
	
	

func on_los_body_entered(body : Node3D)-> void:
	if body is PlayerTank:
		Transitioned.emit(self,EnemyBattleship.STATES.ATTACK)
