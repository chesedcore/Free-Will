class_name IFF extends Node2D

@export var inner: Node2D
@export var outer: Node2D
@export var iff_name: Label

enum State {
	ON_SCREEN,
	FOCUSED,
	LOCKED_ON,
}

var state := State.ON_SCREEN

var t: Tween
@export var time := 0.3

func _ready() -> void:
	setup()

func reset_tween() -> void:
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	t.set_parallel(true)

func to_onscreen() -> void:
	reset_tween()
	state = State.ON_SCREEN
	t.tween_property(outer, "scale", 1.25 * Vector2.ONE, time)
	t.tween_property(outer, "modulate", Color.TRANSPARENT, time)
	t.tween_property(inner, "rotation_degrees", 0, time)
	t.tween_property(inner, "modulate", Color.YELLOW, time)

func to_focused() -> void:
	reset_tween()
	state = State.FOCUSED
	t.tween_property(outer, "scale", Vector2.ONE, time)
	t.tween_property(outer, "modulate", Color.GREEN, time)
	t.tween_property(inner, "rotation_degrees", 0, time)
	t.tween_property(inner, "modulate", Color.GREEN, time)

func to_locked() -> void:
	reset_tween()
	state = State.LOCKED_ON
	t.tween_property(outer, "modulate", Color.RED, time)
	t.tween_property(outer, "scale", Vector2.ONE, time)
	t.tween_property(inner, "modulate", Color.RED, time)
	t.tween_property(inner, "rotation_degrees", 45, time)


func setup() -> void:
	outer.modulate = Color.TRANSPARENT
	outer.scale = 1.25 * Vector2.ONE

func change_state(to: IFF.State) -> void:
	if state == to: return
	match to:
		State.ON_SCREEN: to_onscreen()
		State.FOCUSED: to_focused()
		State.LOCKED_ON: to_locked()

func set_iff(to: String) -> void:
	iff_name.set_text(to)
