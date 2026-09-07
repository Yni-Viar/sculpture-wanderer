extends InteractableRigid
## Made by Yni, licensed under CC0.
## A StaticBody, that can be interacted.

enum Choices {D}

@export var choices: Choices = Choices.D

func interact(player: Node3D):
	match choices:
		Choices.D:
			if !((get_tree().root.get_node("Game").data >> 1) % 2 == 1):
				get_tree().root.get_node("Game/UI/Thinking").text_insert("Sic transit gloria mundi.\nThere is no eternal in our world. Every piece will destroyed by the time...")
				get_tree().root.get_node("Game").data += 2
