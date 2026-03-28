##you can't preload a scene inside its own scene unless you
##really want to corrupt the entire scene that badly.
##this registry preloads those scenes as its own body outside of that scene.
class_name Registry

static func create_cannonfire() -> CannonParticles:
	return preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()

static func create_bullet() -> Bullet:
	return preload("res://scenes/projectiles/tank_bullet.scn").instantiate()

static func create_railgun() -> RailgunParticles:
	return preload("res://scenes/projectiles/railgun_particles.tscn").instantiate()

static func create_missile_explosion() -> ExplosionParticles:
	return preload("res://scenes/projectiles/enemy_projectie/missie_explosion_particles.tscn").instantiate()

static func create_explosion() -> DeathExplosionParticles:
	return preload("res://scenes/entities/explosion_particles.tscn").instantiate()

static func create_railcannonfire() -> RailCannonParticles:
	return preload("res://scenes/entities/railgun_cannon_particles.tscn").instantiate()

static func create_stationary_smoke() -> StationarySmokeParticles:
	return preload("res://scenes/entities/smoke_particles.tscn").instantiate()

static func create_aerial_smoke() -> AerialSmokeParticles:
	return preload("res://scenes/entities/aerial_smoke_particles.tscn").instantiate()
