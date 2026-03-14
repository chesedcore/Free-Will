class_name ShipAttackState extends EnemyState

var cannon_bases : Array[Node3D]
var cannon_barrels : Array[Node3D]
var rotation_speed: float = 5.0
var cannon_aims : Array[RayCast3D]
var fire_time :float = 1.5
var remaining_fire_time: Array[float] =[]
var los : Area3D
const THREAT_INDICATOR = preload("res://scenes/entities/combat/threat_indicator.tscn")
var threat_indicators :Array[ThreatIndicator]
const TANK_CANNON_PARTICLES = preload("res://scenes/entities/tank_cannon_particles.tscn")
@export var impact_sound: AudioStream = preload("res://audio/sfx/explosion.ogg")

func enter() -> void:
	los.body_exited.connect(on_los_body_exited)
	for aim in cannon_aims:
		remaining_fire_time.append(fire_time)
		threat_indicators.append(null)
static  func  ship_attackstate_from(owner : BaseEnemy,bases: Array[Node3D],barrels : Array[Node3D],aims : Array[RayCast3D],los: Area3D)->State:
	var state: ShipAttackState = new()
	state.enemy = owner
	state.player = GameState.player
	state.cannon_bases = bases
	state.cannon_barrels = barrels
	state.los = los
	state.cannon_aims = aims
	return state

func update(_delta : float) -> void:
	for i in cannon_aims.size():
		if cannon_aims[i].is_colliding() and cannon_aims[i].get_collider() == player:
			if remaining_fire_time[i] >= fire_time:
				if threat_indicators[i] == null:
					var indicator : ThreatIndicator = THREAT_INDICATOR.instantiate()
					indicator.target_node = cannon_bases[i]
					player.add_child(indicator)
					threat_indicators[i] = indicator
			remaining_fire_time[i] -= _delta
			if remaining_fire_time[i] <= 0:
				
				shoot(cannon_aims[i].get_collision_point())
				if threat_indicators[i]:
					threat_indicators[i].target_node = null
					threat_indicators[i] = null
				remaining_fire_time[i] = fire_time
		else:
			if threat_indicators[i]:
				threat_indicators[i].target_node = null
				threat_indicators[i] = null
			remaining_fire_time[i] = fire_time

func physics_update(_delta :float) -> void:
	if player:
		for base in cannon_bases:
			var base_pos :Vector3 = base.global_position
			var flat_target : Vector3= player.global_position
			flat_target.y = base_pos.y  
			base.look_at(flat_target, Vector3.UP)
			base.rotation.y = lerp_angle(base.rotation.y, base.rotation.y, rotation_speed * _delta)
		for barrel in cannon_barrels:
			var target_dir : Vector3 = (player.global_position - barrel.global_position)
			var horizontal_dist: float = Vector2(target_dir.x, target_dir.z).length()
			var target_angle :float = atan2(target_dir.y, horizontal_dist)
			barrel.rotation.z = lerp_angle(barrel.rotation.z, target_angle   , rotation_speed * _delta)
			

func on_los_body_exited(body : Node3D)->void:
	if body is PlayerTank:
		Transitioned.emit(self,EnemyBattleship.STATES.IDLE)

func exit() -> void:
	for i in threat_indicators.size():
		if threat_indicators[i]:
			threat_indicators[i].target_node = null
			threat_indicators[i] = null

func shoot(pos:Vector3)->void:
	var explosion :Node3D = TANK_CANNON_PARTICLES.instantiate()
	player.damage(10)
	AudioManager.play_sound_at(pos, impact_sound, 15.0)
	enemy.get_parent().add_child(explosion)
	explosion.global_position = pos
