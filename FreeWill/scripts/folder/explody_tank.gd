extends Node2D

var game_running : bool
var game_over : bool
var scroll : int
var score : int
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pillars : Array[Area2D]
const PILLAR_DELAY := 100
const PILLAR_RANGE := 150

@export var pillar_scene : PackedScene
@export var tank : CharacterBody2D

func _ready() -> void:
	screen_size = get_window().size
	new_game()
	
func new_game() -> void:
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$CanvasLayer.hide()
	$CanvasLayer2/Label.text = "SCORE: " + str(score)
	get_tree().call_group("pillars", "queue_free")
	pillars.clear()
	generate_pillars()
	tank.reset()

func _input(event: InputEvent) -> void:
	if not game_over:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if tank.flying:
						tank.explode()
						check_top()

func start_game() ->void:
	game_running = true
	tank.flying = true
	tank.explode()
	$PillarTimer.start()

func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		for pillar : Area2D in pillars:
			pillar.position.x -= SCROLL_SPEED
		
func _on_pillar_timer_timeout() -> void:
	generate_pillars()

func generate_pillars() -> void:
	var pillar : Area2D = pillar_scene.instantiate()
	pillar.position.x = screen_size.x + PILLAR_DELAY
	pillar.position.y = screen_size.y / 2 + randi_range(-PILLAR_RANGE, PILLAR_RANGE)
	pillar.hit.connect(tank_hit)
	pillar.scored.connect(scored)
	add_child(pillar)
	pillars.append(pillar)

func scored() -> void:
	score += 1
	$CanvasLayer2/Label.text = "SCORE: " + str(score)

func check_top() -> void:
	if tank.position.y < 0:
		tank.falling = true
		stop_game()

func check_bottom() -> void:
	if tank.position.y > screen_size.y:
		tank.falling = true
		stop_game()

func stop_game() -> void:
	$PillarTimer.stop()
	tank.flying = false
	game_running = false
	game_over = true
	$CanvasLayer.show()

func tank_hit() -> void:
	tank.falling = true
	stop_game()


func _on_area_2d_hit() -> void:
	tank.falling = false
	stop_game()


func _on_button_pressed() -> void:
	new_game()
