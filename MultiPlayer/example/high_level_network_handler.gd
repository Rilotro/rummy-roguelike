extends Node

const IP_ADDRESS: String = "LocalHost"
const PORT: int = 42069
var server_IP: String

var peer: ENetMultiplayerPeer

var server_openned: bool = false
var players = {}
var username: String

func start_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		print(error)
		return error
	multiplayer.multiplayer_peer = peer
	
	var ip_adress :String = ""
	
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("linux"):
		if OS.has_environment("HOSTNAME"):
			ip_adress =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	
	if(ip_adress == ""):
		ip_adress = IP_ADDRESS
	
	server_IP = ip_adress
	server_openned = true

func start_client(Server_IP: String, Server_PORT: int):
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_client(Server_IP, Server_PORT)
	if error:
		print(error)
		return error
	server_IP = Server_IP
	
	#var ip_adress :String
#
	#if OS.has_feature("windows"):
		#if OS.has_environment("COMPUTERNAME"):
			#ip_adress =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
			#peer.create_client(ip_adress, PORT)
			#server_IP = ip_adress
		#else:
			#peer.create_client(IP_ADDRESS, PORT)
			#server_IP = IP_ADDRESS
	#else:
		#peer.create_client(IP_ADDRESS, PORT)
		#server_IP = IP_ADDRESS
	multiplayer.multiplayer_peer = peer

func close_server() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	server_openned = false

func new_player(id: int, player_username: String) -> void:
	players[str(id)] = player_username
