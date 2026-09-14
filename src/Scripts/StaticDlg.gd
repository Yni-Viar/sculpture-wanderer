extends InteractableStatic
## Made by Yni, licensed under CC0.
## A StaticBody, that can be interacted.
class_name StaticDlg

enum Choices {C, L, T, R, OI}

@export var choices: Choices = Choices.C

func interact(player: Node3D):
	match choices:
		Choices.C:
			if !(get_tree().root.get_node("Game").data % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("The world was somewhere ago created. All was created!")
				get_tree().root.get_node("Game").data += 1
		Choices.L:
			if !((get_tree().root.get_node("Game").data >> 2) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("Love is powerful - it can connect hearts, or break them into pieces...")
				get_tree().root.get_node("Game").data += 4
		Choices.T:
			if !((get_tree().root.get_node("Game").data >> 3) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("The God probably made a mistake, when He created the humans...\nHumans can be pure devils in terms of torturing other humans...")
				get_tree().root.get_node("Game").data += 8
		Choices.R:
			if !((get_tree().root.get_node("Game").data >> 4) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("What if we are going through infinite cycle of creation or destruction?")
				get_tree().root.get_node("Game").data += 16
		Choices.OI:
			if !((get_tree().root.get_node("Game").data >> 5) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("Good and evil, darkness and brightness, beautifulness and ugliness, natural and artificial...")
				get_tree().root.get_node("Game").data += 32
