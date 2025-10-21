extends Node2D

func _ready() -> void:
	if(HighLevelNetworkHandler.server_openned):
		$VBoxContainer/Server_IP.visible = false
		$PORT_Notice.visible = false

func _on_join_button_pressed() -> void:
	$Username_Tip.self_modulate = Color(1, 1, 1, 1)
	$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 1, 1, 1)
	$PORT_Notice.visible = false
	
	var player_name: String = $VBoxContainer/Player_Name.text
	
	if(HighLevelNetworkHandler.server_openned):
		if(player_name == ""):
			$Username_Tip.self_modulate = Color(1, 0, 0, 1)
		else:
			HighLevelNetworkHandler.username = player_name
			get_tree().change_scene_to_file("res://MultiPlayer/Multiplayer_Lobby.tscn")
		return
	
	var Server_IP: String = $VBoxContainer/Server_IP/IP.text
	var complete: bool = true
	
	if(player_name == ""):
		complete = false
		$Username_Tip.self_modulate = Color(1, 0, 0, 1)
	if(Server_IP == ""):
		complete = false
		$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 0, 0, 1)
	
	if(complete):
		HighLevelNetworkHandler.username = player_name
		var new_Loading:Node2D = preload("res://Loading_Notice.tscn").instantiate()
		add_child(new_Loading)
		new_Loading.global_position = Vector2(576, 324)
		HighLevelNetworkHandler.start_client(Server_IP)
		if(!HighLevelNetworkHandler.client_openned):
			await HighLevelNetworkHandler.peer.joined
		new_Loading.queue_free()
		get_tree().change_scene_to_file("res://MultiPlayer/Multiplayer_Lobby.tscn")


func _on_cancel_button_pressed() -> void:
	HighLevelNetworkHandler.left_join()
	get_tree().change_scene_to_file("res://MultiPlayer/MainMenu.tscn")
