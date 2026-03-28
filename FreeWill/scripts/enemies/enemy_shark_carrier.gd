class_name EnemySharkCarrier extends BaseEnemy
const SHARK = preload("res://scenes/entities/combat/shark.tscn")
const ENEMY_SHIP_BULLET = preload("res://scenes/entities/combat/enemy_ship_bullet.tscn")

var player : PlayerTank
var rotation_speed: float = 5.0
@export var base: MeshInstance3D
@export var shark_spawn_location: Node3D
@export var attack_timer: Timer

@export var smoke_spawners : Array[Marker3D]

var initial_smoke := false

func _physics_process(delta: float) -> void:
	if player:
		
		var base_pos :Vector3 = base.global_position
		var flat_target : Vector3= player.global_position
		flat_target.y = base_pos.y  
		base.look_at(flat_target, Vector3.UP)
		base.rotation.y = lerp_angle(base.rotation.y, base.rotation.y, rotation_speed * delta)

func _on_line_of_sight_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		player = body
		attack_timer.start()

func _on_line_of_sight_body_exited(body: Node3D) -> void:
	if body is PlayerTank:
		if body == player:
			player = null
			attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	if player:
		CannonParticles.attach_to(shark_spawn_location)
		shark_spawn_location.get_child(0).scale = Vector3(3.,3.,3.)
		var new_missile :HomingMissile = SHARK.instantiate()
		
		new_missile.target_node = player
		EventBus.spawn_weaponry.emit(new_missile)
		new_missile.global_position =shark_spawn_location.global_position

func damage(amount: float) -> void:
	super(amount)
	if smoke_spawners.is_empty(): return
	if health <= 150. and not initial_smoke:
		var i : int = 0
		while i < 5:
			StationarySmokeParticles.attach_to(smoke_spawners[i])
			ExplosionParticles.attach_to(smoke_spawners[i])
			i += 1
		initial_smoke = true
	elif health <= 50.:
		var i : int
		if not initial_smoke:
			i = 0
			initial_smoke = true
		else:
			i = 5
		while i < len(smoke_spawners) - 1:
			StationarySmokeParticles.attach_to(smoke_spawners[i])
			ExplosionParticles.attach_to(smoke_spawners[i])
			i += 1

func kill() -> void:
	for smoke_spawner : Marker3D in smoke_spawners:
		DeathExplosionParticles.spawn_at(get_tree(), smoke_spawner, 10.)
	super()
