extends Node

## Scene Manager Class
## This script should be an autoload to be accessed.

var current_scene: Node


func _ready() -> void:
	print_debug("Scene Manager instanced.")

## changes current scene and sets the 'current_scene' variable to new scene instance.
func change_scene(scene_path: String) -> void:
	assert(ResourceLoader.exists(scene_path), "Scene path not valid")

	if (current_scene):
		current_scene.queue_free()

	current_scene = (load(scene_path) as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(current_scene)
	print_debug("Changed Scene: %s" % scene_path)

## Adds a new scene to the tree's root node.
func add_scene_to_root(scene_path: String) -> void:
	assert(ResourceLoader.exists(scene_path), "Scene path not valid")

	var new_scene: Node = (load(scene_path) as PackedScene).instantiate()
	get_tree().root.add_child.call_deferred(new_scene)
	print_debug("Added Scene to root: %s" % scene_path)
