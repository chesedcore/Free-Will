extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Bullet:
		body.freeze = true
		print("blocked")
		body.delete()
