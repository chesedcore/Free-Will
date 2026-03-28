class_name MarqueeContainer extends Control

@export var marquees: Array[Marquee]

func _ready() -> void:
	show()
	_wire_up_signals()

func _wire_up_signals() -> void:
	for marquee in marquees:
		marquee.mouse_entered.connect(marquee.appear)
		marquee.mouse_exited.connect(marquee.disappear)
