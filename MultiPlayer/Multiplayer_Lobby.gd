extends Node2D

func _ready() -> void:
	multiplayer.peer_connected.connect(player_joined)
	if(!multiplayer.is_server()):
		$Button.disabled = true
	else:
		#HighLevelNetworkHandler.players[str(multiplayer.get_unique_id())] = 
		$RichTextLabel.text += HighLevelNetworkHandler.server_IP
		#print("HERE0 - " + str(multiplayer.get_unique_id()))
		var new_PlayerBanner: Control = preload("res://MultiPlayer/Player_Banner.tscn").instantiate()
		new_PlayerBanner.name = str(multiplayer.get_unique_id())
		$VBoxContainer.add_child(new_PlayerBanner)
		HighLevelNetworkHandler.new_player(1, HighLevelNetworkHandler.username)

func player_joined(id: int) -> void:
	if !multiplayer.is_server(): 
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
	#print(HighLevelNetworkHandler.players)
	if multiplayer.is_server():
		start_game.rpc()
	get_tree().change_scene_to_file("res://Board_Test.tscn")

@rpc
func start_game() -> void:
	get_tree().change_scene_to_file("res://Board_Test.tscn")

@rpc("any_peer", "call_local", "reliable")
func add_player(id: int, username: String) -> void:
	HighLevelNetworkHandler.new_player(id, username)
