extends Node3D

@onready var child := $GPUParticles3D

@export var tank : PlayerTank
@export var speed_threshold : float = 90.
@export var wind_trail_num : int = 20

var previous_dir := Vector3.DOWN

#fucking wind lines
var markers : Array[GPUParticles3D] = []

func _ready() -> void:
	if tank:
		for i in range(wind_trail_num):
			var marker := child.duplicate()
			marker.name = str(i)
			add_child(marker)
			marker.emitting = true
			marker.position.x = cos((2.*PI/wind_trail_num) * i + randf_range(-0.25,0.25)) * (15. + randf_range(-2.,5.))
			marker.position.y = sin((2.*PI/wind_trail_num) * i + randf_range(-0.25,0.25)) * (15. + randf_range(-2.,5.))
			markers.append(marker)
	else:
		printerr(self, " tank is null")
		
func _physics_process(delta: float) -> void:
	if tank and not markers.is_empty():
		if tank.linear_velocity.length() > speed_threshold:
			show()
			for each in markers:
				each.position.y = sin((2.*PI/wind_trail_num) * int(each.name) + randf_range(-0.25,0.25)) * (15. + randf_range(-2.,5.))
				each.position.x = cos((2.*PI/wind_trail_num) * int(each.name) + randf_range(-0.25,0.25)) * (15. + randf_range(-2.,5.))
			var velocity_dir := tank.linear_velocity.normalized()
			var face_direction := previous_dir.move_toward(velocity_dir, delta * 10.)
			previous_dir = face_direction
			look_at(face_direction + global_position)
		else:
			hide()
		
