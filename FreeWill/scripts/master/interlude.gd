extends ColorRect

@export var dialog : String
@export var scene_to_transition_to : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start(dialog)
	await Dialogic.timeline_ended
	get_tree().change_scene_to_file(scene_to_transition_to)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
