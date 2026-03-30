class_name  SuperEnemyPlane extends EnemyPlane
@export var decoy_holder: Node3D
const MISSIE_EXPLOSION_PARTICLES = preload("res://scenes/projectiles/enemy_projectie/missie_explosion_particles.tscn")

const DECOY = preload("res://scenes/entities/combat/decoy.tscn")
const DEATHMISSILE = preload("res://scenes/projectiles/enemy_projectie/deathmissile.tscn")

signal decoys_spawned
const  HALF_HP : float = 50
var decoys : Array[Node]=[]
var summoned_decoys : bool = false
func damage(amount: float) -> void:
	super.damage(amount)
	AerialSmokeParticles.attach_to(self)
	#if health <= HALF_HP and !summoned_decoys:
		#summoned_decoys = true
		#for pos :Node3D in decoy_holder.get_children():
			#var new_decoy : Decoy = DECOY.instantiate()
			#pos.add_child.call_deferred(new_decoy)
			#decoys.append(new_decoy)
		#print("summoning")
		#decoys_spawned.emit(decoys)
var dying : bool = false
func kill() -> void:
	if ! dying :
		dying = true
		for decoy in decoys:
			if decoy != null:
				decoy.kill()
		speed = 0
		#Dialogic.Inputs.block_input(100000)
		Dialogic.start("death_missile_warning")
		await  death_animation()
		fire_death_missile()
		super.kill()
		
func fire_death_missile()->void:
	var new_missile :HomingMissile = DEATHMISSILE.instantiate()
	new_missile.target_node = GameState.player
	EventBus.spawn_weaponry.emit(new_missile)
	new_missile.global_position = missle_spawner.global_position

func death_animation()->void:
	var death_tween: Tween = create_tween()
	var duration := 2.0
	var interval := .1
	var count := int(duration / interval)
	for i in count:
		death_tween.tween_callback(explode)
		death_tween.tween_interval(interval)
	death_tween.tween_callback(big_explode)
	await death_tween.finished


func big_explode()->void:
	var explosion :ExplosionParticles = MISSIE_EXPLOSION_PARTICLES.instantiate()
	explosion.scale = scale * 10
	explosion.position = global_position 
	get_tree().current_scene.add_child(explosion)

func explode()->void:
	var explosion :ExplosionParticles = MISSIE_EXPLOSION_PARTICLES.instantiate()
	var offset := Vector3(
		randf_range(-25, 25),
		randf_range(-25, 25),
		randf_range(-25, 25)
	)
	
	explosion.position = global_position + offset
	get_tree().current_scene.add_child(explosion)
