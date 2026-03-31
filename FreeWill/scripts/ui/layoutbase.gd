
extends DialogicLayoutLayer

@export var dialogcontainer: MarginContainer

@export var name_text: DialogicNode_NameLabel

@export var text_margin: MarginContainer
@export var dialog_text: DialogicNode_DialogText
@export var color : Color = Color.GREEN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	text_margin.scale.x = 0
	dialogcontainer.scale.y = 0
	show()
var final_name : String 
var final_dialog : String
func _on_dialogic_signal(argument:String)->void:
	if argument == "end_dia":
		final_name= name_text.text
		final_dialog = dialog_text.text
		hide()



func show()->void:

	var show_tween : Tween= create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	show_tween.tween_property(dialogcontainer,"scale:y",1,.5)
	show_tween.tween_property(text_margin,"scale:x",1,.5)
	await  show_tween.finished


func hide()->void:
	
	var hide_tween : Tween= create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	hide_tween.tween_property(text_margin,"scale:x",0,.5)
	hide_tween.tween_property(dialogcontainer,"scale:y",0,.5)
	name_text.text = final_name
	dialog_text.text = final_dialog 
