extends Node

const SEPARATOR_BYTE: int = 58

var socket: StreamPeerTCP = StreamPeerTCP.new()
#var wrapped_client: PacketPeerStream = PacketPeerStream.new()
var sent: bool = false

func _ready() -> void:
	print("HERE0 - " + str(":".to_utf8_buffer()[0]))
	socket.connect_to_host("127.0.0.1", 65432)
	
	#var test1: Tile = Tile.getRandomTile()
	#
	#var test2: String = "test"
	#
	#var bytes1: PackedByteArray = var_to_bytes(inst_to_dict(test1))
	#test1 = dict_to_inst(bytes_to_var(bytes1))
	#
	#print(test1)

func _process(_delta: float) -> void:
	socket.poll()
	
	#if(!sent && socket.get_status() == socket.STATUS_CONNECTED):
		#var data: PackedByteArray = "print:test".to_utf8_buffer()
		#print("HERE0 - " + str(data.get_string_from_utf8()))
		#socket.put_data(data)
		#sent = true
	
	if(socket.get_status() == socket.STATUS_CONNECTED && socket.get_available_bytes() > 0):
		var data: PackedByteArray = socket.get_data(socket.get_available_bytes())[1]
		
		
		#var sizeIndex: int = data.find(SEPARATOR_BYTE)
		#
		#var size: int = int(data.slice(0, sizeIndex).get_string_from_utf8())
		#
		#var message: PackedByteArray = data.slice(sizeIndex+1)
		#while(message.size() < size):
			#message.append_array(socket.get_data(size-message.size())[1])
		#
		#var sourceIndex: int = message.find(SEPARATOR_BYTE)
		#
		#var source: String = message.slice(0, sourceIndex).get_string_from_utf8()
		#message = message.slice(sourceIndex+1)
		#
		#var commandIndex: int = message.find(SEPARATOR_BYTE)
		#
		#var command: String = message.slice(0, commandIndex).get_string_from_utf8()
		#var params: PackedByteArray = message.slice(commandIndex+1)
		
		var msg: String = data.get_string_from_utf8()
		
		var test: Array[int] = Array(JSON.parse_string(msg), TYPE_INT, "", null)
		#var test: Vector2 = JSON.parse_string(msg)
		
		#var test: Dictionary
		#JSON.parse_string()
		
		#if(command == "tile"):
			#var tile: Tile = dict_to_inst(bytes_to_var(params))
			#
			#print("Message from " + source + ": " + command)
			#print("Tile info: " + str(tile.number) + ", " + str(tile.color))
		#else:
			#print("Message from " + source + ": " + command)

func send_data(command: String, params: PackedByteArray) -> void:
	if(socket.get_status() == socket.STATUS_CONNECTED):
		var data: PackedByteArray = (command + ":").to_utf8_buffer()
		data.append_array(params)
		
		var dataSize: int = data.size()
		#print("HERE0 - " + str(dataSize))
		
		var message = (str(dataSize) + ":").to_utf8_buffer()
		message.append_array(data)
		
		socket.put_data(message)

#func _on_button_pressed() -> void:
	#if(socket.get_status() == socket.STATUS_CONNECTED):
		#var packet: PackedByteArray = "print:test".to_utf8_buffer() #"test".to_utf8_buffer()
		#socket.put_data(packet)
		##wrapped_client.put_var("test")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var quitMsg: PackedByteArray = "quit:self".to_utf8_buffer()
		var message: PackedByteArray = (str(quitMsg.size()) + ":").to_utf8_buffer()
		message.append_array(quitMsg)
		socket.put_data(message)
		socket.disconnect_from_host()
