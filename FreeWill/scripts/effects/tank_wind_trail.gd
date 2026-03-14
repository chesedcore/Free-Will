extends Node3D

@export var trail_renderer_l: TrailRenderer
@export var trail_renderer_r: TrailRenderer
@export var trail_renderer_l2: TrailRenderer
@export var trail_renderer_r2: TrailRenderer

@onready var tank: PlayerTank = owner

func _process(_delta: float) -> void:
	var is_fast: bool = tank.linear_velocity.length() >= 30.0
	if trail_renderer_l and trail_renderer_l2 and trail_renderer_r and trail_renderer_r2:
		trail_renderer_l.is_emitting = is_fast
		trail_renderer_r.is_emitting = is_fast
		trail_renderer_l2.is_emitting = is_fast
		trail_renderer_r2.is_emitting = is_fast
