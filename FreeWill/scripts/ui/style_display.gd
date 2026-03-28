class_name StyleDisplay extends Control

@export var test_rank_label: Label
@export var test_points_label: Label

var style_points: int = 0


func cool_shit(shit: CoolShit.Shit, points: int) -> void:
	# TEMPORARY
	match shit:
		CoolShit.Shit.PARRY:
			print("PARRIED")
		CoolShit.Shit.DODGE:
			print("DODGED")

	style_points += points
	test_points_label.text = "points: %s" % [style_points]
