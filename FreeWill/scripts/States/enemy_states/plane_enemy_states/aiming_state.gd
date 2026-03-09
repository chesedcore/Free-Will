class_name InterceptState extends EnemyState

const HOMING_MISSLE = preload("res://scenes/projectiles/enemy_projectie/homingmissle.tscn")

@export var Max_speed : float = 10.0
@export var aceleration : float = 5
@export var turn_speed : float = 2.5
@export var lock_on_timer: Timer
@export var attack_range :float = 300
@export var retreat_range: float = 25

var velocity_vec : Vector3 = Vector3.ZERO
var heading : Vector3 = Vector3.FORWARD
var player_direction : Vector3
var player_offset : Vector3
var offset_distance : int = randi_range(50,100)

@onready var missle_spawner: Node3D = $"../../missle_spawner"


func enter() -> void:
	heading  = -enemy.global_transform.basis.z
	player_direction =  player.global_position - enemy.global_position

	var basis := enemy.global_transform.basis
	var right := basis.x
	var up := basis.y
	var offset_dirs := [
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

	player_offset = offset_dirs.pick_random() * offset_distance


func physics_update(_delta: float) -> void:
	if enemy and player:
		var forward := -enemy.global_transform.basis.z
		var target := player.global_position + player_offset + forward * 10
		var desired_direction := (target - enemy.global_position).normalized()
		heading = heading.slerp(desired_direction, turn_speed * _delta).normalized()

		velocity_vec = velocity_vec.move_toward(heading * Max_speed, aceleration * _delta)
		enemy.look_at(enemy.global_position + heading, Vector3.UP)
		enemy.velocity = velocity_vec
		if enemy.global_position.distance_to(player.global_position) <= attack_range:
			if forward.dot(target) > 0.5:
				start_lock_on()
			else:
				stop_lock_on()
		else:
			stop_lock_on()
		if enemy.global_position.distance_to(player.global_position) <= retreat_range:
			pass
	#
		#player_direction = Vector3(player.global_position - enemy.global_position ).normalized()
		#var angle := heading.angle_to(player_direction)
		#var max_turn := turn_speed * _delta
		#if angle > max_turn:
			#var axis := heading.cross(player_direction).normalized()
			#heading = heading.rotated(axis, max_turn)
		#else:
			#heading = player_direction
#
		#heading = heading.normalized()
		#enemy.look_at(enemy.global_position + heading, Vector3.UP)
		#velocity_vec = velocity_vec.move_toward(heading * move_speed, 50 * _delta)
		#enemy.velocity = velocity_vec
		#if enemy.global_position.distance_to(player.global_position) <= attack_range:
			#if aim.get_collider():
				#start_lock_on()
			#else:
				#stop_lock_on()
		#if enemy.global_position.distance_to(player.global_position) <= retreat_range:
			#Transitioned.emit(self,"dodgingstate")


func start_lock_on() -> void:
	if  lock_on_timer.is_stopped():
		print("locking on")
		lock_on_timer.start()


func stop_lock_on() -> void:
	lock_on_timer.stop()


func _on_lock_on_timer_timeout() -> void:
	var new_missle :HomingMissle= HOMING_MISSLE.instantiate()
	new_missle.target_node = player
	new_missle.global_transform = missle_spawner.global_transform
	get_tree().root.add_child.call_deferred(new_missle)
