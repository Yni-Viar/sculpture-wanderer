extends Label

func text_insert(value: String) -> void:
	text = value
	get_parent().get_node("AnimationPlayer").play("open")

func clear() -> void:
	text = ""
