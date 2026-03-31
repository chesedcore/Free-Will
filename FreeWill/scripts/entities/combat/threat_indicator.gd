class_name ThreatIndicator extends Node3D

var target_node : Node3D
@export var arrow: Node3D

@onready var mesh: MeshInstance3D = $threat_indicator_model/Cube

var distance : float = 5000.


var flash_timer : float = 0.0
var flash_speed : float = 16
var flash_on : bool = false
var flash_material : StandardMaterial3D


# Called when the node enters the scene tree for thse first time.
func _ready() -> void:
	#beepnoise.pitch_scale = randf_range(0.8, 1.2)
	look_at(target_node.global_position)
	flash_material = mesh.get_surface_override_material(0).duplicate()
	mesh.set_surface_override_material(0, flash_material)
	get_parent().threat_indicators.append(self)
	#start_beeping()

var max_dist : float = 300
var min_dist : float = 100
var scale_speed : float = 4

var parry_indicating : bool = false

func _process(delta: float) -> void:
	
	if target_node == null:
		get_parent().threat_indicators.erase(self)
		queue_free.call_deferred()
	else:
		distance = global_position.distance_to(target_node.global_position)
		var scale_factor := remap(distance, 0, max_dist, 1.25, 0.25)
		scale_factor = clamp(scale_factor, 0.25, 1.25)

		arrow.scale = lerp(arrow.scale, Vector3.ONE * scale_factor,scale_speed* delta)
		look_at(target_node.global_position)
		if distance<= min_dist :
			flash_timer += delta * flash_speed

			if flash_timer >= 1.0:
				flash_timer = 0.0
				flash_on = !flash_on
				flash_material.emission_enabled = flash_on

			parry_indicating = true
		else:
		# TURN OFF when not in range
			if parry_indicating:
				flash_material.emission_enabled = false
				flash_timer = 0.0
				flash_on = false
				parry_indicating = false
		#var beep_time :float = clamp((distance - min_dist) / (max_dist - min_dist), 0.0, 1.0)
		#beeptimer.wait_time = lerp(0.1, 1.0, beep_time)
