class_name DodgingState extends EnemyState

@export var Max_speed : float = 10.0
@export var aceleration : float = 5
@export var turn_speed : float = 2.5
@export var dodge_distance : float = 25
var dodge_offset : Vector3
@export var dodge_duration : float
var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD

var player_direction : Vector3



func enter() -> void:
	
	heading  = -enemy.global_transform.basis.z
	player_direction =  player.global_position - enemy.global_position
	dodge_duration = 3
	var basis := enemy.global_transform.basis
	var right := basis.x
	var up := basis.y
	var dodge_dirs := [
		right,
		-right,
		up,
		-up
	]
	#var dirs := [
		#Vector3.LEFT,
		#Vector3.RIGHT,
		#Vector3.UP,
		#Vector3.DOWN
	#]

	dodge_offset = dodge_dirs.pick_random() * dodge_distance
	


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	if enemy and player:
		if dodge_duration >0 :
			dodge_duration -= _delta
		else:
			Transitioned.emit(self,"interceptstate")

		var forward := -enemy.global_transform.basis.z
		var target := player.global_position + dodge_offset + forward * 10
		var desired_direction := (target - enemy.global_position).normalized()
		heading = heading.slerp(desired_direction, turn_speed * _delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * Max_speed, aceleration * _delta)
		velocity_vec = velocity_vec.limit_length(Max_speed)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = velocity_vec
		
