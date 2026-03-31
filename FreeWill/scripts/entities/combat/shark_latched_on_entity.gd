class_name SharkLatchedOn extends Node3D


@export var duration : float = 3

var latched_on_tank : PlayerTank
var ONFUCKINGFIRE : bool =false
@export var fire: GPUParticles3D

func _ready() -> void:
	if ONFUCKINGFIRE:
		fire.emitting = true
	if  Dialogic.current_timeline == null:
			Dialogic.start("shark_warning")

const PULLFORCE = 5

func _physics_process(delta: float) -> void:
	if latched_on_tank:
		latched_on_tank.linear_velocity.y -=PULLFORCE
		duration -= delta
		if duration<=0 or latched_on_tank.has_a_big_ass_shark_chewing_on_its_ass == false:
			latched_on_tank.has_a_big_ass_shark_chewing_on_its_ass = false
			queue_free.call_deferred()
