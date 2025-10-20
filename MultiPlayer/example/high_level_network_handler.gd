extends Node

const IP_ADDRESS: String = "LocalHost"
const PORT: int = 9999
var server_IP: String

var peer: NodeTunnelPeer = NodeTunnelPeer.new()

var server_openned: bool = false
var players = {}
var username: String

func _ready() -> void:
	multiplayer.multiplayer_peer = peer
	peer.connect_to_relay("relay.nodetunnel.io", 9998)
	await peer.relay_connected

func start_server():
	peer.host()
	await peer.hosting
	
	server_openned = true

func start_client(Server_IP: String):
	peer.join(Server_IP)
	#print(error)
	#if error:
		#print(error)
		#return error
	await peer.joined

func close_server() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	server_openned = false

func new_player(id: int, player_username: String) -> void:
	players[str(id)] = player_username
