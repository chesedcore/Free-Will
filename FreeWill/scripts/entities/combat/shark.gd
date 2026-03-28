class_name Shark extends HomingMissile
const SHARK_LATCHED_ON_ENTITY = preload("res://scenes/entities/combat/shark_latched_on_entity.tscn")

func attach_shark(tank: PlayerTank)->void:
	var new_shark :SharkLatchedOn = SHARK_LATCHED_ON_ENTITY.instantiate()
	new_shark.latched_on_tank = tank
	tank.add_child(new_shark)
	tank.has_a_big_ass_shark_chewing_on_its_ass = true
func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		var res := try_damage_tank(body, damage_value)
		if res.is_err():
			var particles : Node3D = \
				preload("res://scenes/projectiles/missile_parry_particles.tscn").instantiate()
			get_tree().root.add_child(particles)
			particles.basis = global_basis
			particles.position = global_position
			return
			
		if !body.has_a_big_ass_shark_chewing_on_its_ass:
			attach_shark(body)

		if trail_renderer:
			trail_renderer.is_emitting = false
			remove_child(trail_renderer)
			get_tree().root.add_child(trail_renderer)
		queue_free.call_deferred()
