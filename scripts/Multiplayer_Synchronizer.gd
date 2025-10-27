extends MultiplayerSynchronizer

@rpc("any_peer", "call_local", "reliable")
func handle_discard(peer_id: int, discarded_tiles: Array) -> void:
	if(multiplayer.get_unique_id() == peer_id):
		var serialized_array: Array[Dictionary]
		for tile in discarded_tiles:
			serialized_array.append(inst_to_dict(tile.getTileData()))
		
		if(HighLevelNetworkHandler.server_openned):
			handle_discard.rpc(peer_id, serialized_array)
		else:
			handle_discard.rpc_id(1, peer_id, serialized_array)
	else:
		get_parent().peer_discarded(peer_id, discarded_tiles)
		if(HighLevelNetworkHandler.server_openned):
			handle_discard.rpc(peer_id, discarded_tiles)

@rpc("any_peer", "call_local", "reliable")
func handle_Drain(peer_id: int, Drain_pos: int) -> void:
	if(multiplayer.get_unique_id() == peer_id):
		if(!HighLevelNetworkHandler.server_openned):
			handle_Drain.rpc_id(1, peer_id, Drain_pos)
	else:
		get_parent().peer_Drained(peer_id, Drain_pos)
	
	if(HighLevelNetworkHandler.server_openned):
		handle_Drain.rpc(peer_id, Drain_pos)

@rpc("any_peer", "call_local", "reliable")
func handle_newScore(newScore: int, client_ID: int) -> void:
	if(!HighLevelNetworkHandler.server_openned):
		handle_newScore.rpc_id(1, newScore, client_ID)
	else:
		get_parent().newScore(newScore, client_ID)
