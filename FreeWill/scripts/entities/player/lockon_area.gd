class_name LockonArea extends Area3D

const MAX_LOCKON_COUNT: int = 3

var active_icons: Dictionary[BaseEnemy, Node3D]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if (body is BaseEnemy):
		create_lockon_icon(body)


func _on_body_exited(body: Node) -> void:
	if (body is BaseEnemy):
		delete_lockon_icon(body)


func create_lockon_icon(enemy: BaseEnemy) -> void:
	if (active_icons.size() >= MAX_LOCKON_COUNT):
		return

	var new_icon: Node3D = preload("res://scenes/entities/tank_lockon_icon.tscn").instantiate()
	active_icons[enemy] = new_icon
	enemy.add_child.call_deferred(new_icon)


func delete_lockon_icon(enemy: BaseEnemy) -> void:
	if (active_icons.has(enemy)):
		var icon: Node3D = active_icons[enemy]
		active_icons.erase(enemy)
		icon.queue_free()


func get_closest_lockon() -> Node3D:
	# TODO: Bubba:
	# as of right now the lockon system doesn't care how long the player has been
	# locked on.(contrary to what the graphics would have you believe). I'm too tired to bother doing this
	# right now but bullets should only fully lockon if the lockon is RED.

	var closest_lockon_node: Node3D = null

	for node: Node3D in active_icons:
		if (!closest_lockon_node):
			closest_lockon_node = node
			continue

		var closest_node_distance: float = \
			closest_lockon_node.global_position.distance_squared_to(global_position)

		var new_node_distance: float = \
			node.global_position.distance_squared_to(global_position)

		if (new_node_distance < closest_node_distance):
			closest_lockon_node = node

	return closest_lockon_node
