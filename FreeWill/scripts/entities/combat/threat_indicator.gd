class_name ThreatIndicator extends Node3D

var target_node : Node3D
@export var arrow: Node3D
@export var beeptimer: Timer
@export var beepnoise: AudioStreamPlayer3D

@onready var mesh: MeshInstance3D = $threat_indicator_model/Cube

var distance : float = 5000.

# Called when the node enters the scene tree for thse first time.
func _ready() -> void:
	#beepnoise.pitch_scale = randf_range(0.8, 1.2)
	look_at(target_node.global_position)
	#beeptimer.start()
	get_parent().threat_indicators.append(self)
	#start_beeping()

var max_dist : float = 300
var min_dist : float = 75
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
		if distance<= min_dist and !parry_indicating:
			parry_indicating = true
			var material :  = mesh.get_surface_override_material(0).duplicate()
			
			material.emission_enabled = true
			mesh.set_surface_override_material(0,material)
		if distance>= min_dist and parry_indicating:
			parry_indicating = true
			var material :  = mesh.get_surface_override_material(0).duplicate()
			
			material.emission_enabled = false
			mesh.set_surface_override_material(0,material)
		#var beep_time :float = clamp((distance - min_dist) / (max_dist - min_dist), 0.0, 1.0)
		#beeptimer.wait_time = lerp(0.1, 1.0, beep_time)

func _on_beeptimer_timeout() -> void:
	beepnoise.play()
