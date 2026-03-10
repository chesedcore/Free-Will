class_name AttackState extends EnemyState

signal fireMissle

var heading : Vector3


var lock_on_timer : Timer

var max_speed : float = 100
var acceleration : float = 50

@export var attack_range : float = 200.0
@export var attack_angle : float = 0.5

func _init(owner :BaseEnemy,lock_on_timer : Timer) -> void:
	super._init(owner)
	self.lock_on_timer = lock_on_timer


func enter() -> void:
	

	lock_on_timer.timeout.connect(on_locked_on)
	heading = enemy.velocity.normalized()
	lock_on_timer.start()


func  physics_update(_delta :float) -> void:
	if !player_in_attack_range():
		print("Lock off")
		lock_on_timer.stop()
		Transitioned.emit(self,"interceptstate")
		return
	var target_velocity :Vector3 = heading * max_speed
	enemy.velocity = enemy.velocity.move_toward(target_velocity, acceleration * _delta)


func exit() -> void:
	lock_on_timer.stop()

func on_los_body_exit(body : Node3D)->void:
	if body is PlayerTank:
		
		lock_on_timer.stop()
		
	

func on_locked_on()->void:
	if player_in_attack_range():
		
		fireMissle.emit(player)
	else:
		print("lost lock")

	Transitioned.emit(self,"interceptstate")
	
func player_in_attack_range() -> bool:
	if player == null:
		return false
		
	var to_player := player.global_position - enemy.global_position
	var distance := to_player.length()
	
	if distance > attack_range:
		return false
	
	var forward := -enemy.global_transform.basis.z
	var dir := to_player.normalized()
	
	return forward.dot(dir) > attack_angle
