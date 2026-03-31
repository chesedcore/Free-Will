extends CanvasLayer




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().reload_current_scene()
