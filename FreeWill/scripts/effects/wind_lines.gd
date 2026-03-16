extends Node3D

@onready var child := $TrailRenderer

@export var tank : PlayerTank
@export var speed_threshold : float = 90.
@export var wind_trail_num : int = 20
@export var radius : float = 15.

var previous_dir := Vector3.DOWN

var t : float = 0.

#fucking wind lines
var markers : Array[TrailRenderer] = []

func _ready() -> void:
	if tank:
		for i in range(wind_trail_num):
			var marker := child.duplicate()
			marker.name = str(i)
			add_child(marker)
			#marker.emitting = true
			marker.show()
			marker.position.x = cos((2.*PI/wind_trail_num) * i + randf_range(-0.25,0.25)) * (radius + randf_range(-2.,5.))
			marker.position.y = sin((2.*PI/wind_trail_num) * i + randf_range(-0.25,0.25)) * (radius + randf_range(-2.,5.))
			markers.append(marker)
	else:
		printerr(self, " tank is null")
		
func _physics_process(delta: float) -> void:
	if tank and not markers.is_empty():
		if tank.linear_velocity.length() > speed_threshold:
			t += delta * randf_range(-1., 2.)
			for each in markers:
				each.is_emitting = true
				each.position.y = sin((2.*PI/wind_trail_num) * float(each.name) + t + randf_range(-0.05,0.05)) * (radius + randf_range(-0.1,0.1))
				each.position.x = cos((2.*PI/wind_trail_num) * float(each.name) + t + randf_range(-0.05,0.05)) * (radius + randf_range(-0.1,0.1))
			var velocity_dir := tank.linear_velocity.normalized()
			var face_direction := previous_dir.move_toward(velocity_dir, delta * 5.)
			previous_dir = face_direction
			look_at(face_direction + global_position)
		else:
			for each in markers:
				each.is_emitting = false
		
