extends Node

func _ready() -> void:
	var newDeck: LobbyButton = LobbyButton.new()
	
	add_child(newDeck)
	#newDeck.enabled = false
	newDeck.position = Vector2(100, 100)
