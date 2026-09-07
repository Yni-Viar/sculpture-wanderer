extends InteractableStatic
## Made by Yni, licensed under CC0.
## A StaticBody, that can be interacted.

enum Choices {C, L, T}

@export var choices: Choices = Choices.C

func interact(player: Node3D):
	match choices:
		Choices.C:
			if !(get_tree().root.get_node("Game").data % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("The world was somewhere ago created. Maybe it is infinite cycle of creation and destruction?")
				get_tree().root.get_node("Game").data += 1
		Choices.L:
			if !((get_tree().root.get_node("Game").data >> 2) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("Love is powerful - it can connect hearts, or break it into pieces...")
				get_tree().root.get_node("Game").data += 4
		Choices.T:
			if !((get_tree().root.get_node("Game").data >> 3) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("The God probably made a mistake, when He created the humans...\nHumans can be pure devils in terms of torturing other humans...")
				get_tree().root.get_node("Game").data += 8
