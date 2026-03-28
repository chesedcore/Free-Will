class_name AttackState extends EnemyState

signal fireMissle

var heading : Vector3
static  var num_of_attacking_planes : float =0
const  MAX_ATTACKING_PLANES = 4


var lock_on_timer : Timer
#const THREAT_INDICATOR = preload("res://scenes/entities/combat/threat_indicator.tscn")

var speed : float = 100
var acceleration : float = 75
#var attack_range : float = 250.0
#var attack_angle : float = 0.5

var danger_range: float = 100
var is_locked_on : bool = true
var los : Area3D
#var threat_indicator : ThreatIndicator
@warning_ignore("shadowed_variable")
static func attack_state_from(owner : BaseEnemy, lock_on_timer : Timer,los : Area3D)-> EnemyState:
	var state : AttackState = new()
	state.enemy = owner
	state.lock_on_timer = lock_on_timer
	state.los = los
	state.player = GameState.player
	return state


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		num_of_attacking_planes -=1

func enter() -> void:
	num_of_attacking_planes +=1

	lock_on_timer.timeout.connect(on_locked_on)
	heading = enemy.velocity.normalized()
	lock_on_timer.start()
	#threat_indicator = THREAT_INDICATOR.instantiate()
	#threat_indicator.target_node = enemy
	#player.add_child(threat_indicator)
const MIN_ALTITUDE := 250.0
const ALTITUDE_FORCE := 100


func  physics_update(_delta :float) -> void:
	if enemy.global_position.distance_to(player.global_position) <= danger_range:
		print("Lock off")
		lock_on_timer.stop()
		Transitioned.emit(self,EnemyPlane.STATES.EVADE)
		return
	var target_velocity : Vector3 = heading * speed
	
	enemy.velocity = enemy.velocity.move_toward(
		target_velocity,
		acceleration * _delta
	)
	if enemy.global_position.y < MIN_ALTITUDE:
		enemy.velocity.y += ALTITUDE_FORCE * _delta

func exit() -> void:
	lock_on_timer.stop()
	#threat_indicator.queue_free.call_deferred()

func on_los_body_exit(body : Node3D)->void:
	if body is PlayerTank:

		lock_on_timer.stop()



func on_locked_on()->void:
	if is_locked_on:

		fireMissle.emit(player)
		#print("fire")
	else:
		#print("lost lock")
		pass

	Transitioned.emit(self,EnemyPlane.STATES.EVADE)



func on_los_body_exited(body : Node3D)->void:
	if body is PlayerTank:
		is_locked_on = false



#func player_in_attack_range() -> bool:
	#if player == null:
		#return false
		#
	#var to_player := player.global_position - enemy.global_position
	#var distance := to_player.length()
	#
	#if distance > attack_range:
		#return false
	#
	#var forward := -enemy.global_transform.basis.z
	#var dir := to_player.normalized()
	#
	#return forward.dot(dir) > attack_angle
