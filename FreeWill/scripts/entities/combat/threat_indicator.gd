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
var min_dist : float = 25
var scale_speed : float = 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_node == null:
		get_parent().threat_indicators.erase(self)
		call_deferred("queue_free")
	else:
		distance = global_position.distance_to(target_node.global_position)
		var scale_factor := remap(distance, 0, max_dist, 1.25, 0.25)
		scale_factor = clamp(scale_factor, 0.25, 1.25)

		arrow.scale = lerp(arrow.scale, Vector3.ONE * scale_factor,scale_speed* delta)	
		look_at(target_node.global_position)
		#var beep_time :float = clamp((distance - min_dist) / (max_dist - min_dist), 0.0, 1.0)
		#beeptimer.wait_time = lerp(0.1, 1.0, beep_time)

func _on_beeptimer_timeout() -> void:
	beepnoise.play()

func start_beeping() -> void:
	if not beeptimer or not beepnoise: return
	while target_node != null:
		var distance :float = global_position.distance_to(target_node.global_position)
		var beep_time  :float= clamp((distance - min_dist) / (max_dist - min_dist), 0.0, 1.0)
		var delay :float= lerp(0.01, 1.0, beep_time)
		var volume : float = lerp (-10,0,beep_time)
		beepnoise.volume_db = volume
		beepnoise.play()
		await get_tree().create_timer(delay).timeout
