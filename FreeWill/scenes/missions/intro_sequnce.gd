class_name Intro extends Node3D

signal show_manual

const MISSION_1_ACT_1 = preload("res://scenes/missions/mission_1_act1.tscn")
@export var animation_player: AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		animation_player.advance(10)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	EventBus.change_game_container_to.emit(MISSION_1_ACT_1.instantiate())
	show_manual.emit()
