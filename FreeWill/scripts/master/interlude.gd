extends ColorRect

@export var dialog : String
@export var scene_to_transition_to : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start(dialog)
	await Dialogic.timeline_ended
	EventBus.change_game_container_to.emit(load(scene_to_transition_to))
