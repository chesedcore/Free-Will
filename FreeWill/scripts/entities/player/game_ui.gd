class_name GameUI extends CanvasLayer

@export var health_bar: TextureProgressBar
@onready var tank: PlayerTank = owner


func _process(_delta: float) -> void:
	health_display_update()


func health_display_update() -> void:
	health_bar.value = tank.health
	health_bar.max_value = tank.MAX_HEALTH
