extends Node2D

func singleplayer() -> void:
	get_tree().change_scene_to_file("res://Board_Test.tscn")

func multi_player() -> void:
	$VBoxContainer/SP_Button.visible = false
	$VBoxContainer/MP_Button.visible = false
	$VBoxContainer/NS_Button.visible = true
	$VBoxContainer/JS_Button.visible = true
	$VBoxContainer/Cancel_Button.visible = true

func new_server() -> void:
	HighLevelNetworkHandler.start_server()
	get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")

func join_server() -> void:
	##HighLevelNetworkHandler.start_client()
	get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")


func _on_cancel_button_pressed() -> void:
	$VBoxContainer/SP_Button.visible = true
	$VBoxContainer/MP_Button.visible = true
	$VBoxContainer/NS_Button.visible = false
	$VBoxContainer/JS_Button.visible = false
	$VBoxContainer/Cancel_Button.visible = false
