extends Node

const SEPARATOR_BYTE: int = 58

var socket: StreamPeerTCP

signal receivedData(source: String, command: String, params: PackedByteArray)

func open_lobby() -> void:
	socket = StreamPeerTCP.new()
	print("Opening Lobby!")
	var err: Error = socket.connect_to_host("127.0.0.1", 65432)
	print("Current Error is: " + error_string(err))
	if err == OK:
		while(socket.get_status() == StreamPeerTCP.STATUS_CONNECTING):
			socket.poll()
			await get_tree().create_timer(0.0001).timeout
		
		if(socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
			print("Lobby Openned!")
			
			return
		else:
			print("There was an Error Openning the Lobby!")
			
			return
	
	print("Error Openning Lobby: " + error_string(err))

func join_lobby():
	socket = StreamPeerTCP.new()
	print("Entering Lobby!")
	var err: Error = socket.connect_to_host("127.0.0.1", 65432)
	print("Current Error is: " + error_string(err))
	if err == OK:
		while(socket.get_status() != socket.STATUS_CONNECTED):
			await get_tree().create_timer(0.0001).timeout
		
		print("Lobby Entered!")
	
	print("Error Entering Lobby: " + error_string(err))

func send_data(command: String, params: PackedByteArray) -> void:
	if(socket.get_status() == socket.STATUS_CONNECTED):
		var data: PackedByteArray = (command + ":").to_utf8_buffer()
		data.append_array(params)
		
		var dataSize: int = data.size()
		#print("HERE0 - " + str(dataSize))
		
		var message = (str(dataSize) + ":").to_utf8_buffer()
		message.append_array(data)
		
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
		
		var message: PackedByteArray = data.slice(sizeIndex+1)
		while(message.size() < size):
			message.append_array(socket.get_data(size-message.size())[1])
		
		var sourceIndex: int = message.find(SEPARATOR_BYTE)
		
		var source: String = message.slice(0, sourceIndex).get_string_from_utf8()
		message = message.slice(sourceIndex+1)
		
		var commandIndex: int = message.find(SEPARATOR_BYTE)
		
		var command: String = message.slice(0, commandIndex).get_string_from_utf8()
		var params: PackedByteArray = message.slice(commandIndex+1)
		
		print("New Message from " + source + ": " + command)
		
		receivedData.emit(source, command, params)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if(socket != null && socket.get_status() == StreamPeerTCP.STATUS_CONNECTED):
			var quitMsg: PackedByteArray = "quit:self".to_utf8_buffer()
			var message: PackedByteArray = (str(quitMsg.size()) + ":").to_utf8_buffer()
			message.append_array(quitMsg)
			socket.put_data(message)
			socket.disconnect_from_host()
