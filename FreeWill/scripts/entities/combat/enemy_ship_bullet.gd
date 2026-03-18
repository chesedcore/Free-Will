class_name Enemy_bullet extends RigidBody3D

@export_group("Bullet Data")
@export var speed: float = 150.0
@export var damage: float = 25.0
@export var despawn_time: float = 5.0
@export var bullet_model: Node3D

var target: PhysicsBody3D


func _ready() -> void:
	apply_bullet_force()
	get_tree().create_timer(despawn_time).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)


func apply_bullet_force() -> void:
	if target:
		#var dir := global_position.direction_to(target.global_position)
		var predict_time : float = 1
		var predict_target : Vector3
		if target is CharacterBody3D :
			predict_target= target.global_position + target.velocity * predict_time
		elif target is RigidBody3D:
			predict_target= target.global_position + target.linear_velocity * predict_time

		var dir := global_position.direction_to(predict_target)
		linear_velocity = dir * speed
	else:
		linear_velocity = -transform.basis.z * speed


func _process(_delta: float) -> void:
	if linear_velocity.length() > 0:
		bullet_model.look_at(global_position + linear_velocity)


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerTank:
		body.damage(damage)
		queue_free()
