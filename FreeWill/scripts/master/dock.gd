class_name Dock extends Control

func check_safety() -> void:
	assert(get_child_count() <= 1, "A dock can only have one or less children!")

func is_occupied() -> bool:
	check_safety()
	return get_child_count() == 1

func clear() -> void:
	check_safety()
	var child := get_child(0)
	child.queue_free()

func add_content(content: Node) -> void:
	check_safety()
	self.add_child(content)

func ref() -> Option:
	check_safety()
	return Option.Some(get_child(0)) if is_occupied() else Option.None()

func replace_with(content: Node) -> void:
	check_safety()
	clear()
	add_content(content)
