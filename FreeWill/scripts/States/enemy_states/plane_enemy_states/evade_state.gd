class_name EvadeState extends EnemyState

var max_speed : float = 200
var aceleration : float = 50
var turn_speed : float = 1.5
var evade_distance : float = 200
var evade_duration : float = 5

var forward_distance: float = 600

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var evade_offset : Vector3
var evade_target : Vector3


static func evade_state_from(owner : BaseEnemy)-> EvadeState:
	var state : EvadeState= new()
	state.enemy = owner
	state.player = GameState.player
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


func physics_update(_delta: float) -> void:
	if enemy and player:
		if evade_duration >0 :
			evade_duration -= _delta
		else:
			Transitioned.emit(self,EnemyPlane.STATES.INTERCEPT)

		evade_target.y = clamp(evade_target.y,150,100000)
		var desired_direction := (evade_target - enemy.global_position).normalized()

		heading = heading.slerp(desired_direction, turn_speed * _delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * max_speed, aceleration * _delta)
		velocity_vec = velocity_vec.limit_length(max_speed)

		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = velocity_vec
