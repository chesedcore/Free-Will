extends ColorRect

@onready var tank: PlayerTank = owner
@onready var shader_mat: ShaderMaterial = material as ShaderMaterial

func _physics_process(delta: float) -> void:
	if is_instance_valid(tank):
		var fast := tank.linear_velocity.length()
		var mask_edge := 1. - (fast - 50.) / 250. * 0.5
		mask_edge = clampf(mask_edge, 0.4, 1.)
		shader_mat.set_shader_parameter("mask_edge", mask_edge)
