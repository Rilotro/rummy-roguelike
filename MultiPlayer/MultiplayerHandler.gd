extends Node

const SEPARATOR_BYTE: int = 58

var socket: StreamPeerTCP
var players: Array[PlayerData]
var currPlayer: PlayerData
var playersReady: int = 0
var lobbyOwner: bool = false
var player_currTurn: int = 0

signal receivedData(source: String, command: String, params: PackedByteArray)

#func _init() -> void:
	#players.append(PlayerData.new())

func connect_toServer() -> void:
	socket = StreamPeerTCP.new()
	print("Connecting to Server!")
	var err: Error = socket.connect_to_host("127.0.0.1", 60000)#65433
	#socket.
	print("Current Error is: " + error_string(err))
	
	if err == OK:
		while(socket.get_status() == StreamPeerTCP.STATUS_CONNECTING):
			socket.poll()
			await get_tree().create_timer(0.0001).timeout
		
		if(socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
			print("Connected to Server!")
			
			receivedData.connect(receiveData)
			await receivedData
			
			return
		else:
			print("There was an Unnexpected Error Connecting to the Server!")
			
			return
	
	print("There was an Error Connecting to the Server: " + error_string(err))

func disconnectSocket() -> void:
	send_data("quit", "quit".to_utf8_buffer())
	socket.disconnect_from_host()
	
	players.clear()
	
	print("Disconnected from Server!")

func receiveData(_source: String, command: String, params: PackedByteArray) -> void:
	if(command == "client_data"):
		receivedData.disconnect(receiveData)
		currPlayer = PlayerData.new(int(params.get_string_from_utf8()))
		players.append(currPlayer)

func getCurrentActivePlayer() -> PlayerData:
	for player in  players:
		if(player.playerSpace.hasBoard):
			return player
	
	return null

func getPlayer_byID(ID: int) -> PlayerData:
	for player in players:
		if(player.ID == ID):
			return player
	
	return null

func getPlayer_byPlayerSpace(playerSpace: Player) -> PlayerData:
	for player in players:
		if(player.playerSpace == playerSpace):
			return player
	
	return null

#func open_lobby() -> void:
	#socket = StreamPeerTCP.new()
	#print("Opening Lobby!")
	#var err: Error = socket.connect_to_host("127.0.0.1", 65432)
	#print("Current Error is: " + error_string(err))
	#if err == OK:
		#while(socket.get_status() == StreamPeerTCP.STATUS_CONNECTING):
			#socket.poll()
			#await get_tree().create_timer(0.0001).timeout
		#
		#if(socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
			#print("Lobby Openned!")
			#
			#return
		#else:
			#print("There was an Error Openning the Lobby!")
			#
			#return
	#
	#print("Error Openning Lobby: " + error_string(err))
#
#func join_lobby():
	#socket = StreamPeerTCP.new()
	#print("Entering Lobby!")
	#var err: Error = socket.connect_to_host("127.0.0.1", 65432)
	#print("Current Error is: " + error_string(err))
	#if err == OK:
		#while(socket.get_status() != socket.STATUS_CONNECTED):
			#await get_tree().create_timer(0.0001).timeout
		#
		#print("Lobby Entered!")
	#
	#print("Error Entering Lobby: " + error_string(err))

func send_data(command: String, params: PackedByteArray) -> void:
	if(socket == null):
		return
	
	if(socket.get_status() == socket.STATUS_CONNECTED):
		var data: PackedByteArray = (command + ":").to_utf8_buffer()
		data.append_array(params)
		
		var dataSize: int = data.size()
		
		var message = (str(dataSize) + ":").to_utf8_buffer()
		message.append_array(data)
		
		print("Sending message of " + str(dataSize) + " bytes")
		
		socket.put_data(message)

func _process(delta: float) -> void:
	if(socket == null):
		return
	
	socket.poll()
	
	if(socket.get_status() == socket.STATUS_CONNECTED && socket.get_available_bytes() > 0):
		var packet: Array = socket.get_data(socket.get_available_bytes())
		
		var data: PackedByteArray = packet[1]
		
		var sizeIndex: int = data.find(SEPARATOR_BYTE)
		
		var size: int = int(data.slice(0, sizeIndex).get_string_from_utf8())
		
		print("Receiving message of " + str(size) + " bytes")
		var message: PackedByteArray = data.slice(sizeIndex+1)
		while(message.size() < size):
			message.append_array(socket.get_data(size-message.size())[1])
		
		print("Full message has " + str(message.size()) + " bytes")
		
		var sourceIndex: int = message.find(SEPARATOR_BYTE)
		
		var source: String = message.slice(0, sourceIndex).get_string_from_utf8()
		message = message.slice(sourceIndex+1)
		
		var commandIndex: int = message.find(SEPARATOR_BYTE)
		
		var command: String = message.slice(0, commandIndex).get_string_from_utf8()
		var params: PackedByteArray = message.slice(commandIndex+1)
		
		print("New Message from " + source + ": " + command)
		
		receivedData.emit(source, command, params)

func findSubArrayLocation(array: PackedByteArray, subarray: PackedByteArray) -> int:
	assert(array.size() != 0, "Array cannot be empty!")
	assert(subarray.size() != 0, "Subarray cannot be empty!")
	assert(array.size() >= subarray.size(), "Subarray cannot be larger than Array!")
	
	var exists: bool
	for i in range(array.size()-subarray.size()+1):
		exists = true
		for j in range(subarray.size()):
			if(array[i+j] != subarray[j]):
				exists = false
				break
		
		if(exists):
			return i
	
	return -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if(socket != null && socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
			var quitMsg: PackedByteArray = "quit:self".to_utf8_buffer()
			var message: PackedByteArray = (str(quitMsg.size()) + ":").to_utf8_buffer()
			message.append_array(quitMsg)
			socket.put_data(message)
			socket.disconnect_from_host()
