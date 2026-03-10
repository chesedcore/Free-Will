extends Node3D

@export var trail_renderer_l: TrailRenderer
@export var trail_renderer_r: TrailRenderer

@onready var tank: PlayerTank = owner

func _process(_delta: float) -> void:
	var is_fast: bool = tank.linear_velocity.length() > 50.0
	trail_renderer_l.is_emitting = is_fast
	trail_renderer_r.is_emitting = is_fast
