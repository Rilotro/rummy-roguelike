extends Node2D

@onready var MenuButtons: VBoxContainer = $MenuButtons
@onready var SPButton: GoodButton = $MenuButtons/SinglePlayer
@onready var MPButton: GoodButton = $MenuButtons/MultiPlayer
@onready var NSButton: GoodButton = $MenuButtons/NewServer
@onready var JSButton: GoodButton = $MenuButtons/JoinServer
@onready var BButton: GoodButton = $MenuButtons/Back

@onready var ServerForm: VBoxContainer = $ServerForm
@onready var Username: TextEdit = $ServerForm/UsernameInput
@onready var Servername: TextEdit = $ServerForm/ServernameInput

@onready var ServerList: VBoxContainer = $ServerList
@onready var Username_J: TextEdit = $ServerList/UsernameInput

@onready var LobbyRoom: VBoxContainer = $LobbyRoom
@onready var LobbyBanner: Label = $LobbyRoom/LobbyBanner

var currThrobber: Throbber
var chosenUserName: String
var chosenLobbyName: String

#func _ready() -> void:
	#ServerList.add_child(LobbyButton.new("test", ["user1", "user2"], true))
	#HighLevelNetworkHandler.REstart_game()

func singleplayer() -> void:
	#HighLevelNetworkHandler.is_singleplayer = true
	#var newGameScene: GameScene = GameScene.new()
	#get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	get_tree().root.add_child(GameScene.new())
	self.queue_free()

func multi_player() -> void:
	SPButton.visible = false
	MPButton.visible = false
	NSButton.visible = true
	JSButton.visible = true
	BButton.visible = true

func new_server() -> void:
	MenuButtons.visible = false
	ServerForm.visible = true
	#$VBoxContainer/NS_Button.disabled = true
	#$VBoxContainer/JS_Button.disabled = true
	#$VBoxContainer/Cancel_Button.disabled = true
	#
	#var newThrobber: Throbber = Throbber.new()
	##var new_Loading: Node2D = preload("res://Loading_Notice.tscn").instantiate()
	#add_child(newThrobber)
	#newThrobber.global_position = get_viewport_rect().size/2
	#
	#await MultiplayerHandler.open_lobby()
	#
	#newThrobber.queue_free()
	#
	#if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		#print("Entering Lobby!")
	#else:
		#$VBoxContainer/NS_Button.disabled = false
		#$VBoxContainer/JS_Button.disabled = false
		#$VBoxContainer/Cancel_Button.disabled = false
	
	#if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		#get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")
	
	#HighLevelNetworkHandler.start_multiplayer()
	#if(!HighLevelNetworkHandler.relay_connected):
		#await HighLevelNetworkHandler.peer.relay_connected
	#
	#HighLevelNetworkHandler.start_server()
	#if(!HighLevelNetworkHandler.server_openned):
		#await HighLevelNetworkHandler.peer.hosting
	#
	#new_Loading.queue_free()
	#DisplayServer.clipboard_set(HighLevelNetworkHandler.peer.online_id)
	#get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")

func join_server() -> void:
	NSButton.DIS_ENable(false)
	JSButton.DIS_ENable(false)
	BButton.DIS_ENable(false)
	
	#MenuButtons.visible = false
	#ServerList.visible = true
	
	currThrobber = Throbber.new()
	add_child(currThrobber)
	currThrobber.global_position = get_viewport_rect().size/2
	
	await MultiplayerHandler.open_lobby()
	
	if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		MultiplayerHandler.receivedData.connect(populate_server_list)
		
		MultiplayerHandler.send_data("get_servers", ("all").to_utf8_buffer())
		
	
	#get_tree().change_scene_to_file("res://MultiPlayer/Server_Join.tscn")

func _on_cancel_button_pressed() -> void:
	SPButton.visible = true
	MPButton.visible = true
	NSButton.visible = false
	JSButton.visible = false
	BButton.visible = false


func create_server() -> void:
	currThrobber = Throbber.new()
	#var new_Loading: Node2D = preload("res://Loading_Notice.tscn").instantiate()
	add_child(currThrobber)
	currThrobber.global_position = get_viewport_rect().size/2
	
	await MultiplayerHandler.open_lobby()
	
	if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		print("Entering Lobby!")
		
		chosenUserName = Username.text
		chosenLobbyName = Servername.text
		LobbyBanner.text = chosenLobbyName + " (1/4)"
		var params: PackedByteArray = (Servername.text + ":" + Username.text).to_utf8_buffer()
		MultiplayerHandler.send_data("create_lobby", params)
		
		Username.clear()
		Servername.clear()
		
		MultiplayerHandler.receivedData.connect(confirm_create_lobby)
	else:
		cancel_server_creation()

func confirm_create_lobby(source: String, command: String, params: PackedByteArray) -> void:
	if(command == "confirm_create_lobby"):
		MultiplayerHandler.receivedData.disconnect(confirm_create_lobby)
		MultiplayerHandler.receivedData.connect(other_player_joined)
		currThrobber.queue_free()
		ServerForm.visible = false
		
		var newUserBanner: RichTextLabel = RichTextLabel.new()
		newUserBanner.bbcode_enabled = true
		newUserBanner.text = chosenUserName + " - [color=red]Not Ready[/color]"
		newUserBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newUserBanner.custom_minimum_size = Vector2(0, 40)
		
		var newStyleBox: StyleBoxTexture = StyleBoxTexture.new()
		newStyleBox.texture = CanvasTexture.new()
		newStyleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.8)
		
		newUserBanner.add_theme_stylebox_override("normal", newStyleBox)
		newUserBanner.name = "UserBanner1"
		LobbyRoom.add_child(newUserBanner)
		
		LobbyRoom.visible = true

func other_player_joined(source: String, command: String, params: PackedByteArray) -> void:
	if(command == "user_joined_lobby"):
		var username: String = params.get_string_from_utf8()
		
		var newUserBanner: RichTextLabel = RichTextLabel.new()
		newUserBanner.bbcode_enabled = true
		
		newUserBanner.text = username + " - [color=red]Not Ready[/color]"
		newUserBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newUserBanner.custom_minimum_size = Vector2(0, 40)
		
		var newStyleBox: StyleBoxTexture = StyleBoxTexture.new()
		newStyleBox.texture = CanvasTexture.new()
		newStyleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.8)
		
		newUserBanner.add_theme_stylebox_override("normal", newStyleBox)
		newUserBanner.name = "UserBanner" + str(LobbyRoom.get_child_count()-1)
		LobbyRoom.add_child(newUserBanner)
		
		LobbyBanner.text = chosenLobbyName + " (" + str(LobbyRoom.get_child_count()-2) + "/4)"

func cancel_server_creation() -> void:
	ServerForm.visible = false
	Username.clear()
	Servername.clear()
	
	SPButton.visible = true
	MPButton.visible = true
	NSButton.visible = false
	JSButton.visible = false
	BButton.visible = false
	
	MenuButtons.visible = true

func populate_server_list(source: String, command: String, params: PackedByteArray) -> void:
	if(command == "server_list"):
		MenuButtons.visible = false
		currThrobber.queue_free()
		MultiplayerHandler.receivedData.disconnect(populate_server_list)
		
		var serverList: Array[Array] = Array(JSON.parse_string(params.get_string_from_utf8()), TYPE_ARRAY, "", null)
		
		var newServerBanner: LobbyButton
		#var styleBox: StyleBoxTexture
		var bannerIndex: int = 0
		for server: Array in serverList:
			bannerIndex += 1
			
			newServerBanner = LobbyButton.new(server[0], Array(server.slice(1), TYPE_STRING, "", null), true)
			newServerBanner.name = "Banner" + str(bannerIndex)
			ServerList.add_child(newServerBanner)
		
		ServerList.visible = true
	elif(command == "server_list_empty"):
		MenuButtons.visible = false
		currThrobber.queue_free()
		MultiplayerHandler.receivedData.disconnect(populate_server_list)
		
		var newServerBanner: RichTextLabel = RichTextLabel.new()
		newServerBanner.custom_minimum_size = Vector2(0, 40)
		newServerBanner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		newServerBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newServerBanner.text = "Server List Empty"
		
		var styleBox: StyleBoxTexture = StyleBoxTexture.new()
		styleBox.texture = CanvasTexture.new()
		styleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.6)
		
		newServerBanner.add_theme_stylebox_override("normal", styleBox)
		newServerBanner.name = "Banner"
		ServerList.add_child(newServerBanner)
		
		ServerList.visible = true

func confirm_join_lobby(source: String, command: String, params: PackedByteArray) -> void:
	if(command == "confirm_join_lobby"):
		MultiplayerHandler.receivedData.disconnect(confirm_join_lobby)
		MultiplayerHandler.receivedData.connect(other_player_joined)
		ServerList.visible = false
		currThrobber.queue_free()
		
		var users_inLobby: Array[String] = Array(JSON.parse_string(params.get_string_from_utf8()), TYPE_STRING, "", null)
		
		LobbyBanner.text = chosenLobbyName + " (" + str(users_inLobby.size()+1) + "/4)"
		
		var bannerIndex: int = 1
		var newUserBanner: RichTextLabel
		var newStyleBox: StyleBoxTexture
		for user in users_inLobby:
			newUserBanner = RichTextLabel.new()
			newUserBanner.bbcode_enabled = true
			newUserBanner.text = user + " - [color=red]Not Ready[/color]"
			newUserBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			newUserBanner.custom_minimum_size = Vector2(0, 40)
			
			newStyleBox = StyleBoxTexture.new()
			newStyleBox.texture = CanvasTexture.new()
			newStyleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.8)
			
			newUserBanner.add_theme_stylebox_override("normal", newStyleBox)
			newUserBanner.name = "UserBanner" + str(bannerIndex)
			LobbyRoom.add_child(newUserBanner)
			
			bannerIndex += 1
		
		newUserBanner = RichTextLabel.new()
		newUserBanner.bbcode_enabled = true
		newUserBanner.text = chosenUserName + " - [color=red]Not Ready[/color]"
		newUserBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newUserBanner.custom_minimum_size = Vector2(0, 40)
		
		newStyleBox = StyleBoxTexture.new()
		newStyleBox.texture = CanvasTexture.new()
		newStyleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.8)
		
		newUserBanner.add_theme_stylebox_override("normal", newStyleBox)
		newUserBanner.name = "UserBanner" + str(bannerIndex)
		LobbyRoom.add_child(newUserBanner)
		
		LobbyRoom.visible = true
