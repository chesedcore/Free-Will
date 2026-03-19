extends MarginContainer

@export var name_text: RichTextLabel
@export var text_margin: MarginContainer
@export var dialog_text: RichTextLabel
@export var dialog_audio: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_margin.scale.x = 0
	scale.y = 0
	await get_tree().create_timer(1)
	show_dialog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_dialog()->void:
	dialog_text.text = "is this what you want?"
	var show_tween : Tween= create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	show_tween.tween_property(self,"scale:y",1,.5)
	show_tween.tween_property(text_margin,"scale:x",1,.5)
	await  show_tween.finished
	hide_dialog()

func hide_dialog()->void:
	var hide_tween : Tween= create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	hide_tween.tween_property(text_margin,"scale:x",0,.5)
	hide_tween.tween_property(self,"scale:y",0,.5)
	
	
