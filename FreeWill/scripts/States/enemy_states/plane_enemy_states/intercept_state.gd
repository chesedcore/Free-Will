class_name InterceptState extends EnemyState


@export var Max_speed : float = 200.0
@export var aceleration : float = 50
@export var turn_speed : float = 1.5
var velocity :Vector3
var rot :Vector3
#@export var detect_range : float = 200.0
#@export var detect_angle : float = 0.7

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var player_offset : Vector3
var offset_distance : int = randi_range(50,65)

var los : Area3D


static func intercept_state_from(owner : BaseEnemy,los:Area3D)-> EnemyState:
	var intercept_state : InterceptState= new()
	intercept_state.enemy = owner
	intercept_state.los = los
	intercept_state.player = GameState.player
	return intercept_state


func enter() -> void:
	los.body_entered.connect(on_los_body_entered)
	velocity_vec = enemy.velocity
	heading = - enemy.global_basis.z
	

	var basis := enemy.global_transform.basis
	var right := basis.x
	var up := basis.y
	var offset_dirs := [
	
	(right + up).normalized(),
	(right - up).normalized(),
	(-right + up).normalized(),
	(-right - up).normalized()
]	
	player_offset = offset_dirs.pick_random() * offset_distance


func physics_update(_delta: float) -> void:
	
	
		var forward := -enemy.global_transform.basis.z
		var target := player.global_position + player_offset + forward * 50
		target.y = clamp(target.y,150,100000)
		var desired_direction := (target - enemy.global_position).normalized()
		heading = heading.slerp(desired_direction, turn_speed * _delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * Max_speed, aceleration * _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = velocity_vec


#
#func update(_delta : float) -> void:
	#if enemy and player:
		#if player_in_front():
			#start_lock_on()
			#return

func start_lock_on() -> void:
	if AttackState.num_of_attacking_planes < AttackState.MAX_ATTACKING_PLANES:
		Transitioned.emit(self,EnemyPlane.STATES.ATTACK)
	#lock_on_timer.start()


func on_los_body_entered(body: Node3D)->void:
	if body is PlayerTank:
		start_lock_on()


#func player_in_front() -> bool:
	#if player == null:
		#return false
		#
	#var to_player :Vector3 = player.global_position - enemy.global_position
	#var distance :float = to_player.length()
	#
	#if distance > detect_range:
		#return false
	#
	#var forward : = -enemy.global_transform.basis.z
	#var dir := to_player.normalized()
	#
	#var dot := forward.dot(dir)
	#return dot > detect_angle
