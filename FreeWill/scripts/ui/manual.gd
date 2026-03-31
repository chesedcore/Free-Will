class_name Manual extends Control

var t: Tween
var on_screen := false
signal get_out
@export var leave_2: PauseMenuButton

func _ready() -> void:
	leave_2.clicked.connect(get_out.emit)
	hide()

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func appear() -> void:
	print("appeared")
	on_screen = true
	show()
	reset_tween()
	t.tween_property(self, "scale:y", 1.0, 0.325)

func disappear() -> void:
	print("disappeared")
	on_screen = false
	reset_tween()
	t.tween_property(self, "scale:y", 0.0, 0.325)
	t.finished.connect(_on_disappeared, CONNECT_ONE_SHOT)

func _on_disappeared() -> void:
	hide()
