extends Node2D

func _ready() -> void:
	multiplayer.peer_connected.connect(player_joined)
	if(!HighLevelNetworkHandler.server_openned):
		$Button.disabled = true
	else:
		$RichTextLabel.text += HighLevelNetworkHandler.peer.online_id
		$RichTextLabel.visible = true
		
		var new_PlayerBanner: Control = preload("res://MultiPlayer/Player_Banner.tscn").instantiate()
		new_PlayerBanner.name = str(multiplayer.get_unique_id())
		$VBoxContainer.add_child(new_PlayerBanner)
		HighLevelNetworkHandler.new_player(1, HighLevelNetworkHandler.username)

func player_joined(id: int) -> void:
	if(!HighLevelNetworkHandler.server_openned): 
		if(id == 1):
			add_player.rpc_id(1, multiplayer.get_unique_id(), HighLevelNetworkHandler.username)
		return
	var new_PlayerBanner: Control = preload("res://MultiPlayer/Player_Banner.tscn").instantiate()
	new_PlayerBanner.name = str(id)
	$VBoxContainer.add_child(new_PlayerBanner)

func _on_button_pressed() -> void:
	for Player in $VBoxContainer.get_children():
		if(!Player.is_ready()):
			$Ready_Notice.visible = true
			return
	if(HighLevelNetworkHandler.server_openned):
		for i in range(multiplayer.get_peers().size()):
			HighLevelNetworkHandler.new_player(multiplayer.get_peers()[i], $VBoxContainer.get_child(i+1).get_username())
		start_game.rpc()
	get_tree().change_scene_to_file("res://Board_Test.tscn")

@rpc
func start_game() -> void:
	get_tree().change_scene_to_file("res://Board_Test.tscn")

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, username: String) -> void:
	print("HERE1")
	HighLevelNetworkHandler.new_player(id, username)
