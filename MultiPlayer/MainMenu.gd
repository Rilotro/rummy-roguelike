extends Node2D

const MAX_PLAYERS_IN_LOBBY: int = 4

@onready var MenuButtons: Control = $MenuButtons
@onready var SPButton: GoodButton = $MenuButtons/SinglePlayer
@onready var MPButton: GoodButton = $MenuButtons/MultiPlayer
@onready var NSButton: GoodButton = $MenuButtons/NewServer
@onready var JSButton: GoodButton = $MenuButtons/JoinServer
@onready var BButton: GoodButton = $MenuButtons/Back

@onready var ServerForm: Control = $ServerForm
@onready var Username: TextEdit = $ServerForm/UsernameInput
@onready var Servername: TextEdit = $ServerForm/ServernameInput
@onready var ErrorText: RichTextLabel = $ServerForm/ErrorText

@onready var ServerList: Control = $ServerList
@onready var Username_J: TextEdit = $ServerList/UsernameInput
@onready var ServerButtons: Control = $ServerList/ServerButtons
@onready var SL_BackButton: GoodButton = $ServerList/Back
var origBackButton_pos: float = 0

@onready var LobbyRoom: Control = $LobbyRoom
@onready var LobbyBanner: Label = $LobbyRoom/LobbyBanner
@onready var PlayerList: VBoxContainer = $LobbyRoom/Players
@onready var Ready: GoodButton = $LobbyRoom/Ready
@onready var StartGame: GoodButton = $LobbyRoom/StartGame
@onready var QuitLobby: GoodButton = $LobbyRoom/Back

var currThrobber: Throbber
var chosenUserName: String
var chosenLobbyName: String
var isReady: bool = false

func _ready() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var separation: int = ServerList.get_theme_constant("separation")
	var space: float = -separation
	for child in ServerList.get_children():
		space += separation
		if(child == ServerButtons):
			continue
		
		space += (child as Control).size.y
	
	BButton.text = BButton.text
	
	ServerButtons.custom_minimum_size.y = screen_size.y - space - 10
	
	PlayerList.custom_minimum_size.y = MAX_PLAYERS_IN_LOBBY*40 + (MAX_PLAYERS_IN_LOBBY-1)*PlayerList.get_theme_constant("separation")
	
	origBackButton_pos = SL_BackButton.position.y
	
	#var LobbyButtons: HBoxContainer = LobbyRoom.get_child(-1)
	#var newLength: float = LobbyButtons.size.x - LobbyButtons.get_theme_constant("separation") - (LobbyButtons.get_child(0) as GoodButton).size.x - (LobbyButtons.get_child(2) as GoodButton).size.x
	#(LobbyButtons.get_child(1) as Control).custom_minimum_size.x = newLength
	
	#space += separation
	#space += 
	
	#ServerList.add_child(LobbyButton.new("test", ["user1", "user2"], true))
	#HighLevelNetworkHandler.REstart_game()

#MAIN MENU BUTTONS
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
	
	ErrorText.visible = false
	ServerForm.visible = true

func join_server() -> void:
	NSButton.enabled = false
	JSButton.enabled = false
	BButton.enabled = false
	
	#MenuButtons.visible = false
	#ServerList.visible = true
	
	currThrobber = Throbber.new()
	add_child(currThrobber)
	currThrobber.global_position = get_viewport_rect().size/2
	
	await MultiplayerHandler.connect_toServer()
	
	if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		MultiplayerHandler.receivedData.connect(populate_server_list)
		
		MultiplayerHandler.send_data("get_servers", ("all").to_utf8_buffer())
	else:
		currThrobber.queue_free()
		MultiplayerHandler.disconnectSocket()

func _on_cancel_button_pressed() -> void:
	SPButton.visible = true
	MPButton.visible = true
	NSButton.visible = false
	JSButton.visible = false
	BButton.visible = false

#LOBBY CREATION
func create_server() -> void:
	chosenUserName = Username.text
	chosenLobbyName = Servername.text
	
	if(chosenLobbyName.is_empty() || chosenUserName.is_empty()):
		ErrorText.visible = true
		return
	
	currThrobber = Throbber.new()
	add_child(currThrobber)
	currThrobber.global_position = get_viewport_rect().size/2
	
	await MultiplayerHandler.connect_toServer()
	MultiplayerHandler.players[0].name = chosenUserName
	MultiplayerHandler.players[0].order = 0
	
	if(MultiplayerHandler.socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
		print("Entering Lobby!")
		
		LobbyBanner.text = chosenLobbyName + " (1/4)"
		var params: PackedByteArray = (Servername.text + ":" + Username.text).to_utf8_buffer()
		MultiplayerHandler.send_data("create_lobby", params)
		
		MultiplayerHandler.receivedData.connect(create_lobby_response)
	else:
		cancel_server_creation()

func create_lobby_response(_source: String, command: String, params: PackedByteArray) -> void:
	if(command == "confirm_create_lobby"):
		MultiplayerHandler.receivedData.disconnect(create_lobby_response)
		MultiplayerHandler.receivedData.connect(otherPlayer_lobbyActions)
		MultiplayerHandler.lobbyOwner = true
		#MultiplayerHandler.receivedData.connect(player_toggleReady)
		currThrobber.queue_free()
		ServerForm.visible = false
		ErrorText.visible = false
		Username.clear()
		Servername.clear()
		
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
		PlayerList.add_child(newUserBanner)
		
		var newLength: float = (300 - Ready.size.x - StartGame.size.x - QuitLobby.size.x)/2
		StartGame.position.x = Ready.size.x + newLength
		QuitLobby.position.x = Ready.size.x + StartGame.size.x + 2*newLength
		
		Ready.position.y += newUserBanner.size.y
		StartGame.position.y += newUserBanner.size.y
		QuitLobby.position.y += newUserBanner.size.y
		
		StartGame.visible = true
		
		LobbyRoom.visible = true
	elif(command == "create_lobby_failed"):
		MultiplayerHandler.receivedData.disconnect(create_lobby_response)
		MultiplayerHandler.disconnectSocket()
		currThrobber.queue_free()
		
		print("The Server Failed to oppen the Lobby!")
		print(params.get_string_from_utf8())

func cancel_server_creation() -> void:
	ServerForm.visible = false
	Username.clear()
	Servername.clear()
	
	_on_cancel_button_pressed()
	MenuButtons.visible = true

#JOINING LOBBY
func populate_server_list(_source: String, command: String, params: PackedByteArray) -> void:
	if(command == "server_list"):
		MenuButtons.visible = false
		currThrobber.queue_free()
		MultiplayerHandler.receivedData.disconnect(populate_server_list)
		NSButton.enabled = true
		JSButton.enabled = true
		BButton.enabled = true
		
		var serverList: Array[Array] = Array(JSON.parse_string(params.get_string_from_utf8()), TYPE_ARRAY, "", null)
		
		var newServerBanner: LobbyButton
		#var styleBox: StyleBoxTexture
		var bannerIndex: int = 0
		for server: Array in serverList:
			bannerIndex += 1
			
			newServerBanner = LobbyButton.new(server[0], Array(server.slice(1), TYPE_STRING, "", null), true)
			newServerBanner.name = "Banner" + str(bannerIndex)
			newServerBanner.position.y = 44*(bannerIndex-1)
			ServerButtons.add_child(newServerBanner)
		
		SL_BackButton.position.y += LobbyButton.BUTTON_HEIGHT*serverList.size()
		
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
		ServerButtons.add_child(newServerBanner)
		
		ServerList.visible = true

func refresh_list() -> void:
	for child in ServerButtons.get_children():
		child.queue_free()
	
	SL_BackButton.position.y = origBackButton_pos
	
	currThrobber = Throbber.new()
	add_child(currThrobber)
	MultiplayerHandler.receivedData.connect(populate_server_list)
	
	MultiplayerHandler.send_data("get_servers", ("all").to_utf8_buffer())

func cancel_join_lobby() -> void:
	MultiplayerHandler.disconnectSocket()
	ServerList.visible = false
	Username_J.clear()
	for serverButton in ServerButtons.get_children():
		serverButton.queue_free()
	
	_on_cancel_button_pressed()
	MenuButtons.visible = true

func confirm_join_lobby(_source: String, command: String, params: PackedByteArray) -> void:
	if(command == "confirm_join_lobby"):
		MultiplayerHandler.receivedData.disconnect(confirm_join_lobby)
		MultiplayerHandler.receivedData.connect(otherPlayer_lobbyActions)
		#MultiplayerHandler.receivedData.connect(player_toggleReady)
		ServerList.visible = false
		currThrobber.queue_free()
		Username_J.clear()
		
		for serverButton in ServerButtons.get_children():
			serverButton.queue_free()
		
		MultiplayerHandler.players[0].name = chosenUserName
		
		var users_inLobby: Array[String] = Array(JSON.parse_string(params.get_string_from_utf8()), TYPE_STRING, "", null)
		
		LobbyBanner.text = chosenLobbyName + " (" + str(users_inLobby.size()+1) + "/4)"
		
		var bannerIndex: int = 1
		var newUserBanner: RichTextLabel
		var newStyleBox: StyleBoxTexture
		var userData: PackedStringArray
		var username: String
		var userID: int
		var newPlayer: PlayerData
		for user in users_inLobby:
			userData = user.split(":")
			username = userData[0]
			userID = int(userData[1])
			newPlayer = PlayerData.new(userID)
			MultiplayerHandler.players.append(newPlayer)
			newPlayer.name = username
			newPlayer.order = bannerIndex-1
			
			newUserBanner = RichTextLabel.new()
			newUserBanner.bbcode_enabled = true
			newUserBanner.text = username + " - "
			if(userData[2] == "True"):
				MultiplayerHandler.playersReady += 1
				newUserBanner.text += "[color=green]Ready[/color]"
			elif(userData[2] == "False"):
				newUserBanner.text += "[color=red]Not Ready[/color]"
			
			newUserBanner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			newUserBanner.custom_minimum_size = Vector2(0, 40)
			
			newStyleBox = StyleBoxTexture.new()
			newStyleBox.texture = CanvasTexture.new()
			newStyleBox.modulate_color = Color(0.1, 0.1, 0.1, 0.8)
			
			newUserBanner.add_theme_stylebox_override("normal", newStyleBox)
			newUserBanner.name = "UserBanner" + str(bannerIndex)
			PlayerList.add_child(newUserBanner)
			
			bannerIndex += 1
		
		MultiplayerHandler.players[0].order = bannerIndex-1
		
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
		PlayerList.add_child(newUserBanner)
		
		var newLength: float = 300 - Ready.size.x - QuitLobby.size.x
		QuitLobby.position.x = Ready.size.x + newLength
		
		Ready.position.y += newUserBanner.size.y * (users_inLobby.size()+1)
		StartGame.position.y += newUserBanner.size.y * (users_inLobby.size()+1)
		QuitLobby.position.y += newUserBanner.size.y * (users_inLobby.size()+1)
		
		StartGame.visible = false
		
		LobbyRoom.visible = true

func otherPlayer_lobbyActions(source: String, command: String, params: PackedByteArray) -> void:
	if(command == "user_joined_lobby"):
		if(MultiplayerHandler.lobbyOwner):
			StartGame.enabled = false
		
		var username: String = params.get_string_from_utf8()
		var newPlayer: PlayerData = PlayerData.new(int(source))
		MultiplayerHandler.players.append(newPlayer)
		var playersSize: int = MultiplayerHandler.players.size()
		newPlayer.name = username
		newPlayer.order = playersSize-1
		
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
		PlayerList.add_child(newUserBanner)
		
		LobbyBanner.text = chosenLobbyName + " (" + str(playersSize) + "/4)"
		
		Ready.position.y += newUserBanner.size.y
		StartGame.position.y += newUserBanner.size.y
		QuitLobby.position.y += newUserBanner.size.y
	elif(command == "toggle_ready"):
		var playerReadiness: String = params.get_string_from_utf8()
		assert(playerReadiness == "true" || playerReadiness == "false", "Message Parameter Value is Unknown!")
		
		var otherPlayer: PlayerData = MultiplayerHandler.getPlayer_byID(int(source))
		var playerBanner: RichTextLabel = PlayerList.get_child(otherPlayer.order)
		playerBanner.text = otherPlayer.name + " - "
		if(playerReadiness == "true"):
			MultiplayerHandler.playersReady += 1
			playerBanner.text += "[color=green]Ready[/color]"
			if(MultiplayerHandler.lobbyOwner && MultiplayerHandler.playersReady >= MultiplayerHandler.players.size()):
				StartGame.enabled = true
		else:
			MultiplayerHandler.playersReady -= 1
			playerBanner.text += "[color=red]Not Ready[/color]"
			if(MultiplayerHandler.lobbyOwner):
				StartGame.enabled = false
	elif(command == "start_game"):
		get_tree().root.add_child(GameScene.new())
		self.queue_free()

func toggleReady() -> void:
	isReady = !isReady
	
	MultiplayerHandler.send_data("toggle_ready", str(isReady).to_utf8_buffer())
	
	var myBanner: RichTextLabel = PlayerList.get_child(MultiplayerHandler.currPlayer.order)
	myBanner.text = MultiplayerHandler.currPlayer.name + " - "
	if(isReady):
		MultiplayerHandler.playersReady += 1
		myBanner.text += "[color=green]Ready[/color]"
		if(MultiplayerHandler.lobbyOwner && MultiplayerHandler.playersReady >= MultiplayerHandler.players.size()):
			StartGame.enabled = true
	else:
		MultiplayerHandler.playersReady -= 1
		myBanner.text += "[color=red]Not Ready[/color]"
		if(MultiplayerHandler.lobbyOwner):
			StartGame.enabled = false

func startGame() -> void:
	MultiplayerHandler.send_data("start_game", "settings_cammel".to_utf8_buffer())
	
	get_tree().root.add_child(GameScene.new())
	self.queue_free()
