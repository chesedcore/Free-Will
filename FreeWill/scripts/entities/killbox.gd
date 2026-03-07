class_name Killbox extends Area3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if (body is PlayerTank):
		# TODO: Bubba: eventually make an actual death screen and shit.
		print("PLAYER HIT WATER. GAME OVER AND STUFF.")
		get_tree().reload_current_scene.call_deferred()
