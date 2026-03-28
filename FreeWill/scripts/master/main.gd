class_name Master extends Control

@export var game_dock: Dock
@export var main_menu_dock: Dock

func _ready() -> void:
	game_dock.add_content(preload("res://scenes/master/game_container.tscn").instantiate())
