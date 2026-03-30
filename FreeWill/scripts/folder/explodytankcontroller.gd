extends CharacterBody2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
@export var EXPLODE_SPEED : int = -450
var flying : bool = false
var falling : bool = false
const START_POS = Vector2(200, 400)

@export var particles : GPUParticles2D
@export var particles2 : GPUParticles2D


func _ready() -> void:
	reset()

func reset() -> void:
	falling = false
	flying = false
	global_position = START_POS
	set_rotation(0.)
	
func _physics_process(delta: float) -> void:
	if flying or falling:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * -0.05) + 0.4)
		elif falling:
			set_rotation(0.)
		move_and_collide(velocity * delta)

func explode() -> void:
	velocity.y = EXPLODE_SPEED
	particles.restart()
	particles2.restart()
