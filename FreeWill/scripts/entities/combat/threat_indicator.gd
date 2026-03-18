class_name ThreatIndicator extends Node3D

var target_node : Node3D
@export var arrow: Node3D
@onready var mesh: MeshInstance3D = $threat_indicator_model/Cube

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	look_at(target_node.global_position)

var max_dist : float = 300
var scale_speed : float = 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_node == null:
		call_deferred("queue_free")
	else:
		var distance := global_position.distance_to(target_node.global_position)
		var scale_factor := remap(distance, 0, max_dist, 1.25, 0.25)
		scale_factor = clamp(scale_factor, 0.25, 1.25)

		arrow.scale = lerp(arrow.scale, Vector3.ONE * scale_factor,scale_speed* delta)
		look_at(target_node.global_position)
