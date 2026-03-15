##you can't preload a scene inside its own scene unless you
##really want to corrupt the entire scene that badly.
##this registry preloads those scenes as its own body outside of that scene.
class_name Registry

static func create_cannonfire() -> CannonParticles:
	return preload("res://scenes/entities/tank_cannon_particles.tscn").instantiate()

static func create_bullet() -> Bullet:
	return preload("res://scenes/projectiles/tank_bullet.scn").instantiate()
