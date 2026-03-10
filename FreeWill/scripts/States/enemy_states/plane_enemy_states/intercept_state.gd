class_name InterceptState extends EnemyState


@export var Max_speed : float = 200.0
@export var aceleration : float = 50
@export var turn_speed : float = 1.5
@export var detect_range : float = 200.0
@export var detect_angle : float = 0.7

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var player_offset : Vector3
var offset_distance : int = randi_range(50,65)


var marker : MeshInstance3D

func _init(owner :BaseEnemy) -> void:
	super._init(owner)
	


func enter() -> void:
	
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
		var desired_direction := (target - enemy.global_position).normalized()
		heading = heading.slerp(desired_direction, turn_speed * _delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * Max_speed, aceleration * _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = velocity_vec
		marker.global_position = target

#
func update(_delta : float) -> void:
	if enemy and player:
		if player_in_front():
			start_lock_on()
			return

func start_lock_on() -> void:
		
		Transitioned.emit(self,"attackstate")
		#lock_on_timer.start()
#

func player_in_front() -> bool:
	if player == null:
		return false
		
	var to_player :Vector3 = player.global_position - enemy.global_position
	var distance :float = to_player.length()
	
	if distance > detect_range:
		return false
	
	var forward : = -enemy.global_transform.basis.z
	var dir := to_player.normalized()
	
	var dot := forward.dot(dir)
	return dot > detect_angle
