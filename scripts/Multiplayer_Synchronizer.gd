extends MultiplayerSynchronizer

var is_handling: bool = false

@rpc("any_peer", "call_local", "reliable")
func handle_discard(peer_id: int, discarded_tiles: Array) -> void:
	if(multiplayer.get_unique_id() == peer_id && !is_handling):
		var serialized_array: Array[Dictionary]
		for tile in discarded_tiles:
			serialized_array.append(inst_to_dict(tile.getTileData()))
		
		is_handling = true
		handle_discard.rpc(peer_id, serialized_array)
		is_handling = false
	elif(multiplayer.get_unique_id() != peer_id):
		get_parent().peer_discarded(peer_id, discarded_tiles)

@rpc("any_peer", "call_local", "reliable")
func handle_Drain(peer_id: int, Drain_pos: int) -> void:
	if(multiplayer.get_unique_id() == peer_id && !is_handling):
		is_handling = true
		handle_Drain.rpc(peer_id, Drain_pos)
		is_handling = false
	elif(multiplayer.get_unique_id() != peer_id):
		get_parent().peer_Drained(peer_id, Drain_pos)
	

@rpc("any_peer", "call_local", "reliable")
func handle_newScore(newScore: int, client_ID: int) -> void:
	if(!HighLevelNetworkHandler.server_openned):
		handle_newScore.rpc_id(1, newScore, client_ID)
	else:
		get_parent().newScore(newScore, client_ID)

@rpc("any_peer", "call_local", "reliable")
func handle_NextTurn(peer_ID: int, viable_peer: int = -1) -> void:
	if(viable_peer < 0):
		if(HighLevelNetworkHandler.server_openned):
			var current_peer: int
			var server_checked: bool = false
			#viable_peer = multiplayer.get_unique_id()
			if(peer_ID == multiplayer.get_unique_id()):
				current_peer = 0
				server_checked = true
			else:
				current_peer = multiplayer.get_peers().find(peer_ID)+1
				if(current_peer >= multiplayer.get_peers().size()):
					current_peer = 0
			
			for i in range(multiplayer.get_peers().size()+1):
				if(current_peer == 0 && !server_checked):
					server_checked = true
					if(get_parent().players[str(multiplayer.get_unique_id())] >= 0):
						viable_peer = multiplayer.get_unique_id()
						break
				else:
					var next_peer: int = multiplayer.get_peers()[current_peer]
					if(get_parent().players[str(next_peer)] >= 0):
						viable_peer = next_peer
						break
					else:
						current_peer += 1
						if(current_peer >= multiplayer.get_peers().size()):
							current_peer = 0
			if(viable_peer >= 0):
				handle_NextTurn.rpc(peer_ID, viable_peer)
		else:
			handle_NextTurn.rpc_id(1, peer_ID, viable_peer)
	else:
		get_parent().Next_Turn(peer_ID, viable_peer)
