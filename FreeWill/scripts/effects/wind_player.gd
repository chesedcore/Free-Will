class_name WindPlayer extends Node3D

@export var wind_low3d : AudioStreamPlayer3D
@export var wind_mid3d : AudioStreamPlayer3D
@export var wind_high3d : AudioStreamPlayer3D
@export var wind_low : AudioStreamPlayer
@export var wind_mid : AudioStreamPlayer
@export var engine : AudioStreamPlayer3D

@export var is_player : bool = true

var previous_speed : float = 0.

func _ready() -> void:
	if is_player:
		wind_low.play()
		wind_mid.play()
	else:
		wind_low3d.play()
		wind_mid3d.play()
	update_wind_mixing(0.)

func update_wind_mixing(speed: float) -> void:
	var lerped_speed : float = lerpf(previous_speed, speed, 0.05)
	previous_speed = lerped_speed
	#print(speed, " lerped: ", lerped_speed)
	wind_low3d.volume_db = remap(clamp(lerped_speed, 0, 400), 50, 400, -40., -5)
	wind_mid3d.volume_db = remap(clamp(lerped_speed, 0, 450), 0, 450, -60, 0)
	wind_mid3d.pitch_scale = remap(clamp(lerped_speed, 0, 450), 0, 450, 0.8, 1.3)

	wind_low.volume_db = remap(clampf(lerped_speed, 0, 400), 95, 400, -10., 14)
	wind_mid.volume_db = remap(clampf(lerped_speed, 0, 450), 95, 450, -10, 5)
	wind_mid.pitch_scale = remap(clampf(lerped_speed, 0, 450), 95, 450, 0.8, 1.5)


	var filter : AudioEffect = AudioServer.get_bus_effect(AudioServer.get_bus_index("Wind"), 0)
	filter.cutoff_hz = remap(clamp(lerped_speed, 0, 400), 0, 400, 1000, 8000)
