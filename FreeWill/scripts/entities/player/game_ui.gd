class_name GameUI extends CanvasLayer

@onready var tank: PlayerTank = owner
@export var temp_health_display_label: Label


func _process(_delta: float) -> void:
	health_display_update()


func health_display_update() -> void:
	temp_health_display_label.text = "Health: %s" % [tank.health]
