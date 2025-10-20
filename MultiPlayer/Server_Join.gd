extends Node2D

func _ready() -> void:
	if(HighLevelNetworkHandler.server_openned):
		$VBoxContainer/Server_IP.visible = false
		#$Username_Tip.visible = false
		$PORT_Notice.visible = false

func _on_join_button_pressed() -> void:
	$Username_Tip.self_modulate = Color(1, 1, 1, 1)
	$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 1, 1, 1)
	$PORT_Notice.visible = false
	$PORT_Notice.text = "PORT must be a number"
	
	var player_name: String = $VBoxContainer/Player_Name.text
	
	if(HighLevelNetworkHandler.server_openned):
		if(player_name == ""):
			$Username_Tip.self_modulate = Color(1, 0, 0, 1)
		else:
			HighLevelNetworkHandler.username = player_name
			get_tree().change_scene_to_file("res://MultiPlayer/Multiplayer_Lobby.tscn")
		return
	
	#var player_name: String = $VBoxContainer/Player_Name.text
	var Server_IP: String = $VBoxContainer/Server_IP/IP.text
	var Server_PORT: String =  $VBoxContainer/Server_IP/PORT.text
	var complete: bool = true
	
	if(player_name == ""):
		complete = false
		$Username_Tip.self_modulate = Color(1, 0, 0, 1)
	if(Server_IP == "" || Server_PORT == ""):
		complete = false
		$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 0, 0, 1)
	elif(Server_PORT != "" && !Server_PORT.is_valid_int()):
		complete = false
		$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 0, 0, 1)
		$PORT_Notice.visible = true
	
	if(complete):
		HighLevelNetworkHandler.start_client(Server_IP)
		#if(error):
			#$VBoxContainer/Server_IP/ServerIP_Tip.self_modulate = Color(1, 0, 0, 1)
			#$PORT_Notice.text = "Server IP or PORT are incorect"
			#$PORT_Notice.visible = true
		#else:
		HighLevelNetworkHandler.username = player_name
		get_tree().change_scene_to_file("res://MultiPlayer/Multiplayer_Lobby.tscn")


func _on_cancel_button_pressed() -> void:
	HighLevelNetworkHandler.close_server()
	get_tree().change_scene_to_file("res://MultiPlayer/MainMenu.tscn")
