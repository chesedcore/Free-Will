class_name Bomb extends BaseEnemy
const MISSIE_EXPLOSION_PARTICLES = preload("res://scenes/projectiles/enemy_projectie/missie_explosion_particles.tscn")

const EXPLOSION = preload("res://audio/sfx/explosion.ogg")

@export var explosion_timer: Timer
var trigger_body : PlayerTank
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fall_to_height()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fall_to_height()-> void:
	var height_range : float = randi_range(60,1600)
	var fall_tween :Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	fall_tween.tween_property(self,"global_position:y",height_range,3)
	await  fall_tween.finished
	explosion_timer.start()


func _on_body_entered(body: Node3D) -> void:

	if body is PlayerTank:
		
		trigger_body = body
func _on_explosion_timer_timeout() -> void:
	model.visible = false
	if trigger_body:
		trigger_body.damage(25)
	
	AudioManager.play_sound_at(global_position,EXPLOSION)
	
	kill()
	
func kill() -> void:
	IFFTracker.stop_tracking_entity(self)
	DeathExplosionParticles.spawn_at(get_tree(), self)
	queue_free.call_deferred()

func _on_body_exited(body: Node3D) -> void:
	if trigger_body:
		if  body == trigger_body:
			trigger_body = null
