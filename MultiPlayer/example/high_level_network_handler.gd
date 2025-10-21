extends Node

const IP_ADDRESS: String = "LocalHost"
const PORT: int = 9999
var server_IP: String

var peer: NodeTunnelPeer = NodeTunnelPeer.new()

var server_openned: bool = false
var players = {}
var username: String

var relay_connected: bool = false
var is_multiplayer: bool = false
var is_singleplayer: bool = false

func REstart_game():
	is_singleplayer = false
	is_multiplayer = false
	server_openned = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	relay_connected = false
	peer.connect_to_relay("relay.nodetunnel.io", 9998)
	await peer.relay_connected
	relay_connected = true

func _ready() -> void:
	pass

func start_multiplayer() -> void:
	is_multiplayer = true
	multiplayer.multiplayer_peer = peer

func start_server():
	if(!relay_connected):
		await peer.relay_connected
	peer.host()
	await peer.hosting
	server_openned = true

var client_openned: bool = false

func start_client(Server_IP: String):
	if(!relay_connected):
		await peer.relay_connected
	peer.join(Server_IP)
	await peer.joined
	client_openned = true

func new_player(id: int, player_username: String) -> void:
	print("HERE2")
	players[str(id)] = player_username

func left_join() -> void:
	peer = NodeTunnelPeer.new()
