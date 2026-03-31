class_name Master extends Control

@export var game_dock: Dock
@export var main_menu_dock: Dock
@export var main_menu: MainMenu

func _ready() -> void:
	wire_up_signals()

func wire_up_signals() -> void:
	main_menu.start_game.connect(_on_game_started)

func _on_game_started() -> void:
	main_menu.queue_free()
	var main_game := preload("res://scenes/master/game_container.tscn").instantiate() as GameContainer
	game_dock.add_content(main_game)
