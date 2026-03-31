class_name HomingMissile extends CharacterBody3D

const THREAT_INDICATOR = preload("res://scenes/entities/combat/threat_indicator.tscn")

@export var target_node : PhysicsBody3D
@export var sender : PhysicsBody3D
@export var Max_speed : float = 250
@export var turn_speed : float =5
@export var fire: GPUParticles3D

@export var damage_value: float = 10.0
@export var impact_sound: AudioStream = preload("res://audio/sfx/explosion.ogg")
@export var spawn_sound: AudioStream = preload("res://audio/sfx/rocket_launch_2.ogg")

@export var hitbox : Area3D

@export var trail_renderer: TrailRenderer

var locked_on : bool = true
@export var lock_off_dist : float = 15
@export var lifespan : float = 5
var threat_indicator : ThreatIndicator
var parried := false

var lifetime := 0.
var ONFUCKINGFIRE:bool = false
func _process(_delta: float) -> void:
	if global_position.y <= -10:
		var trail := trail_renderer
		if is_instance_valid(trail):
			trail.is_emitting = false
			remove_child(trail)
			get_tree().root.add_child(trail)
		queue_free.call_deferred()

func  _ready() -> void:
	if ONFUCKINGFIRE:
		fire.emitting = true
	AudioManager.play_sound_at(global_position, spawn_sound, 10.0)

	if target_node:
		threat_indicator = THREAT_INDICATOR.instantiate()
		threat_indicator.target_node = self
#		threat_indicator.is_dangerous = true
		target_node.add_child(threat_indicator)


func _physics_process(delta: float) -> void:
	if trail_renderer:
		trail_renderer.position.x = randf_range(-0.5,.5)
		trail_renderer.position.y = 0.524 + randf_range(-0.5,0.5)
	if not target_node and not parried:
		return
	elif parried:
		locked_on = false

	if locked_on and target_node:
		var distance : float = global_position.distance_to(target_node.global_position)
		var speed :float= max(velocity.length(), 0.01)
		var predict_time : float = min(distance/ speed,0.075)
		var predict_target : Vector3

		if target_node is CharacterBody3D :
			predict_target= target_node.global_position + target_node.velocity * predict_time
		elif target_node is RigidBody3D:
			predict_target= target_node.global_position + target_node.linear_velocity * predict_time
		
		var dir_to_predict : Vector3 = (predict_target - global_position).normalized()
		var forward : Vector3 = -global_transform.basis.z
		var new_dir :Vector3= forward.slerp(dir_to_predict, turn_speed * delta).normalized()

		look_at(global_position + new_dir, Vector3.UP)

		if distance<lock_off_dist:
			locked_on = false
			if threat_indicator:
				threat_indicator.target_node = null


	if lifespan > lifetime:
		lifetime += delta
		velocity = -global_transform.basis.z * Max_speed
	else:
		if threat_indicator:
			threat_indicator.target_node = null
		locked_on = false
		velocity += get_gravity() *2 * delta

	move_and_slide()

func try_damage_tank(body: PlayerTank, amount: float) -> Result:
	var result := body.try_damage(amount)
	if result.is_ok(): return result

	#now we know that the attack failed.
	var reason: ParryReport = result.unwrap_err()

	print_rich("[color=red]PARRIED")
	UIBus.missile_parried.emit()

	match reason.type:
		ParryReport.Type.NORMAL: deflect_this_missile()

	return result

func deflect_this_missile() -> void:
	if sender:
		parried = true
		if threat_indicator:
			threat_indicator.target_node = null
		locked_on = true
		target_node = sender
		lifetime = 0.
		hitbox.set_collision_mask_value(3, true)
	else:
		if threat_indicator:
			threat_indicator.target_node = null
		locked_on = false
	flip_basis.call_deferred()

func _on_hitbox_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		var res := try_damage_tank(body, damage_value)
		if res.is_err():
			ParryParticles.attach_to(get_tree(), global_basis, global_position)
			return
		ExplosionParticles.attach_to(body)

		AudioManager.play_sound_at(global_position, impact_sound, 15.0)
		if trail_renderer:
			trail_renderer.is_emitting = false
			remove_child(trail_renderer)
			get_tree().root.add_child(trail_renderer)
		queue_free.call_deferred()
	elif body is BaseEnemy:
		body.damage(50)
		ExplosionParticles.attach_to(body)
		AudioManager.play_sound_at(global_position, impact_sound, 15.0)
		if trail_renderer:
			trail_renderer.is_emitting = false
			remove_child(trail_renderer)
			get_tree().root.add_child(trail_renderer)
		queue_free.call_deferred()


func flip_basis() -> void:
	basis = basis.rotated(self.basis.y, 3.141592653589793)
