extends Node2D

func _ready() -> void:
	HighLevelNetworkHandler.REstart_game()

func singleplayer() -> void:
	HighLevelNetworkHandler.is_singleplayer = true
	get_tree().change_scene_to_file("res://Board_Test.tscn")

func multi_player() -> void:
	$VBoxContainer/SP_Button.visible = false
	$VBoxContainer/MP_Button.visible = false
	$VBoxContainer/NS_Button.visible = true
	$VBoxContainer/JS_Button.visible = true
	$VBoxContainer/Cancel_Button.visible = true

func new_server() -> void:
	$VBoxContainer/NS_Button.disabled = true
	$VBoxContainer/JS_Button.disabled = true
	$VBoxContainer/Cancel_Button.disabled = true
	
	var new_Loading:Node2D = preload("res://Loading_Notice.tscn").instantiate()
	add_child(new_Loading)
	new_Loading.global_position = Vector2(576, 324)
	
	HighLevelNetworkHandler.start_multiplayer()
	if(!HighLevelNetworkHandler.relay_connected):
		await HighLevelNetworkHandler.peer.relay_connected
	
	HighLevelNetworkHandler.start_server()
	if(!HighLevelNetworkHandler.server_openned):
		await HighLevelNetworkHandler.peer.hosting
	
	new_Loading.queue_free()
	get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")

func join_server() -> void:
	$VBoxContainer/NS_Button.disabled = true
	$VBoxContainer/JS_Button.disabled = true
	$VBoxContainer/Cancel_Button.disabled = true
	
	var new_Loading:Node2D = preload("res://Loading_Notice.tscn").instantiate()
	add_child(new_Loading)
	new_Loading.global_position = Vector2(576, 324)
	
	HighLevelNetworkHandler.start_multiplayer()
	if(!HighLevelNetworkHandler.relay_connected):
		await HighLevelNetworkHandler.peer.relay_connected
	
	new_Loading.queue_free()
	get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")


func _on_cancel_button_pressed() -> void:
	$VBoxContainer/SP_Button.visible = true
	$VBoxContainer/MP_Button.visible = true
	$VBoxContainer/NS_Button.visible = false
	$VBoxContainer/JS_Button.visible = false
	$VBoxContainer/Cancel_Button.visible = false
