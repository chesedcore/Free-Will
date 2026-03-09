extends ColorRect

const SCALE = 0.01

@onready var tank: PlayerTank = owner
@onready var shader_mat: ShaderMaterial = material as ShaderMaterial


func _process(_delta: float) -> void:
	speed_lines_update()


func speed_lines_update() -> void:
	shader_mat.set_shader_parameter("intensity", tank.linear_velocity.length() * SCALE)
