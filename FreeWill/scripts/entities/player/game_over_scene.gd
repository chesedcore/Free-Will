class_name GameOverScene extends Node

const ROT_SPEED: float = 0.25

@export var camera_rot_point: Node3D
@export var camera: Camera3D

@export var retry_button: Button
@export var menu_button: Button
var completed : bool = false
var player: PlayerTank
@export var label: Label


func _ready() -> void:
	if completed:
		label.text = "Mission Complete"
	camera.make_current()
	camera_rot_point.global_position = player.global_position

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	retry_button.pressed.connect(retry)
	menu_button.pressed.connect(return_to_menu)


func _physics_process(delta: float) -> void:
	camera_rot_point.rotation.y += ROT_SPEED * delta

const MISSION_SELECT = preload("res://scenes/ui/mission_select.tscn")

func retry() -> void:
	IFFTracker.clear_tracked_entities()

	# Bubba:
	# When we have actual stages this should be replaced with something that is not as shit.
	queue_free.call_deferred()
	get_tree().reload_current_scene.call_deferred()



func return_to_menu() -> void:
	# Bubba:
	# When we can this should be replaced with a main menu
	IFFTracker.clear_tracked_entities()
	get_tree().change_scene_to_packed.call_deferred(MISSION_SELECT)
