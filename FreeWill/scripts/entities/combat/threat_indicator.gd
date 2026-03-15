class_name ThreatIndicator extends Node3D

var target_node : Node3D

@onready var mesh: MeshInstance3D = $threat_indicator_model/Cube
#var is_dangerous : bool = false
var visible_range : float = 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(target_node.global_position)
	#if is_dangerous:
		#change_to_red()


func change_to_red()-> void:
	var material  :Material = mesh.get_surface_override_material(0)
	if material:
		material = material.duplicate()
		
		material.albedo_color = Color(1.0, 0.0, 0.0) 
		mesh.set_surface_override_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_node == null:
		queue_free.call_deferred()
	else:
		#if global_position.distance_to(target_node.global_position)<visible_range and visible == false:
			#visible = true
		#else :
			#visible = false			
		look_at(target_node.global_position)
