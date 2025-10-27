extends Node2D

@export var players: Dictionary = {}
var stats: Array[int] = [0, 0, 0, 0]#in order: Score, Biggest Spread (Score-Wise), Times Spread, Tiles Bought

var PB: Node2D

func _ready() -> void:
	PB = $Player_Board
	if(HighLevelNetworkHandler.is_multiplayer):
		if(HighLevelNetworkHandler.is_multiplayer ):
			players[str(1)] = 0
		for id in multiplayer.get_peers():
			if(HighLevelNetworkHandler.server_openned):
				players[str(id)] = 0
			var new_PB: Sprite2D = preload("res://ProgressBar.tscn").instantiate()
			new_PB.owner_id = id
			$MultiplayerControl.add_child(new_PB)
			match $MultiplayerControl.get_child_count():
				1:
					new_PB.global_position = Vector2(100, 320)
				2:
					new_PB.global_position = Vector2(530, 100)
	
	$Turn_Button.text = "Shop"
	$Shop.visible = false
	$Shop.REgenerate_selections()
	
	var nex_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size($Discard_Tip.text)
	$Discard_Tip.size = nex_X_size
	$Discard_Tip.global_position.x -= nex_X_size.x/2
	
	if(HighLevelNetworkHandler.is_multiplayer && HighLevelNetworkHandler.server_openned):
		$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(1)] + "'s Turn"
		var tween = get_tree().create_tween()
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
		#await get_tree().create_timer(1).timeout
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
	elif(HighLevelNetworkHandler.is_singleplayer):
		PB.Activate_Draw()

@rpc("any_peer", "call_local", "reliable")
func client_NewScore(client_id: int, newScore: int):
	players[str(client_id)] = -players[str(client_id)]

func getTurn() -> bool:
	return PB.my_turn

func Start_Turn(GameOver: bool = false) -> void:
	if(GameOver):
		if(HighLevelNetworkHandler.is_multiplayer):
			if(HighLevelNetworkHandler.server_openned):
				players[str(multiplayer.get_unique_id())] = -players[str(multiplayer.get_unique_id())]
			else:
				client_NewScore.rpc_id(1, multiplayer.get_unique_id(), -players[str(multiplayer.get_unique_id())])
		End_Turn()
		$GameOver_Screen.GameOver(stats)
	else:
		$Turn_Button.text = "End Turn"
		$Turn_Button.self_modulate = Color(1, 1, 1, 1)

func Next_Turn():
	if(HighLevelNetworkHandler.is_singleplayer):
		PB.Activate_Draw()
	if(HighLevelNetworkHandler.is_multiplayer):
		if(HighLevelNetworkHandler.server_openned):
			var viable_player: int = multiplayer.get_unique_id()
			for peer in multiplayer.get_peers():
				if(players[str(peer)] >= 0):
					viable_player = peer
					break
			
			$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(viable_player)] + "'s Turn"
			var new_tween = get_tree().create_tween()
			new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
			#await get_tree().create_timer(1).timeout
			new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
			new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
			
			if(viable_player != multiplayer.get_unique_id()):
				pass
			else:
				PB.Activate_Draw()
		#else:
			#server_get_newScore.rpc_id(1, multiplayer.get_unique_id(), -Score)
			#client_EndTurn.rpc_id(1, multiplayer.get_unique_id())

func _process(_delta: float) -> void:
	if(HighLevelNetworkHandler.is_multiplayer):
		if(players.size() >= multiplayer.get_peers().size()+1):
			for Peer_ProgressBoard in $MultiplayerControl.get_children():
				var acc_score: int = players[str(Peer_ProgressBoard.owner_id)]
				if(Peer_ProgressBoard.currentScore != acc_score && !Peer_ProgressBoard.is_updating):
					Peer_ProgressBoard.uodateScore(acc_score)

func select_tiles(nr_tiles: int = 3):
	$TileSelect_Screen.start_select(nr_tiles)

func newScore(newScore: int, client_ID: int):
	$Shop.update_currency(newScore)
	if(HighLevelNetworkHandler.is_multiplayer):
		if(HighLevelNetworkHandler.server_openned):
			players[str(client_ID)] += newScore 
		elif(client_ID == multiplayer.get_unique_id()):
			$MultiplayerSynchronizer.handle_newScore(newScore, client_ID)

func addShopUses():
	$Shop.addShopUses()

func used_PassiveItem(item_ID: int):
	$ItemBar.used_PassiveItem(item_ID)

func add_ItemSlot() -> void:
	$ItemBar.add_ItemSlot()

func buy_tile(tile_bought: Tile_Info) -> void:
	stats[3] += 1
	$Player_Board.add_tile_to_deck(tile_bought)

func buy_item(item_bought: Item) -> void:
	$ItemBar.add_item(item_bought)

func Gain_Freebie(freebies: int = 1) -> void:
	$Shop.Gain_Freebie(freebies)

var Base_Tile: PackedScene = preload("res://Tile.tscn")

func peer_discarded(peer_id: int, peer_DT: Array):
	if(peer_id == multiplayer.get_unique_id()):
		$MultiplayerSynchronizer.handle_discard(peer_id, peer_DT)
	else:
		var discarded_tiles: Array[Tile]
		var new_tile: Tile
		var deserialized_tile: Tile_Info
		for serialezed_tile in peer_DT:
			new_tile = Base_Tile.instantiate()
			deserialized_tile = dict_to_inst(serialezed_tile)
			new_tile.change_info(Tile_Info.new(0, 0, 0, "", deserialized_tile))
			discarded_tiles.append(new_tile)
		#PB.add_to_River(discarded_tiles)

func End_Turn():
	$Turn_Button.text = "Shop"
	$Turn_Button.self_modulate = Color(1, 1, 1, 1)
	Tile.select_Color = Color(1, 1, 0, 1)
	$Shop.REgenerate_selections()
	
	var tween = get_tree().create_tween()
	tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
	Next_Turn()

#if(HighLevelNetworkHandler.is_multiplayer):
		#if(HighLevelNetworkHandler.server_openned):
			#var viable_player: int = 1
			#for peer in multiplayer.get_peers():
				#if(players[str(peer)] >= 0):
					#viable_player = peer
					#break
			#
			#$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(viable_player)] + "'s Turn"
			#var new_tween = get_tree().create_tween()
			#new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
			##await get_tree().create_timer(1).timeout
			#new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
			#new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
			#
			#if(viable_player != 1):
				#next_turn.rpc(viable_player)
			#elif(Score >= 0):
				#next_turn(1)
		#else:
			#client_EndTurn.rpc_id(1, multiplayer.get_unique_id())
	#elif(HighLevelNetworkHandler.is_singleplayer):
		#next_turn(1)

#@rpc
#func multiplayer_discard(client_id: int, Tile_Discarded) -> void:
	#if(multiplayer.get_unique_id() != client_id):
		#var tile = dict_to_inst(Tile_Discarded)
		#var new_tile: Tile = Base_Tile.instantiate()
		#new_tile.change_info(Tile_Info.new(0, 0, 0, "", tile))
		#add_child(new_tile)
		#Discard_River.append(new_tile)
		#update_board_tile_positions()

#@rpc
#func next_turn(next_client: int) -> void:
	#if(multiplayer.get_unique_id() == next_client):
		#$Deck_Counter/Deck_Highlight.visible = true
		#$Deck_Counter/StartTurn_Draw.disabled = false
#
#@rpc("any_peer", "call_local", "reliable")
#func client_EndTurn(client_id: int):
	#var client_index: int = multiplayer.get_peers().find(client_id)+1
	#if(client_index >= multiplayer.get_peers().size()):
		#client_index = 0
	#var server_checked: bool = false
	#var viable_player: bool = false
	#for i in range(multiplayer.get_peers().size()+1):
		#if(client_index == 0 && !server_checked):
			#client_id = 1
			#if(Score >= 0):
				#viable_player = true
				#break
			#else:
				#server_checked = true
				#continue
		#client_id = multiplayer.get_peers()[client_index]
		#if(players[str(client_id)] >= 0):
			#viable_player = true
			#break
		#else:
			#client_index += 1
			#if(client_index >= multiplayer.get_peers().size()):
				#client_index = 0
	#
	#if(viable_player):
		#var turn_username: String = HighLevelNetworkHandler.players[str(client_id)]
		#$Player_Turn_Announcer.text = "It's " + turn_username + "'s Turn"
		#var tween = get_tree().create_tween()
		#tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
		##await get_tree().create_timer(1).timeout
		#tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
		#tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
		#
		#if(client_id == 1):
			#next_turn(1)
		#else:
			#next_turn.rpc(client_id)
	#else:
		#pass

#@rpc("any_peer", "call_local", "reliable")
#func client_Drain(client_id: int, Drain_Start: int):
	#if(Drain_Start >= 0):
		#var new_River: Array[Tile]
		#for i in range(Drain_Start):
			#new_River.append(Discard_River[i])
		#for i in range(Drain_Start, Discard_River.size()):
			#Discard_River[i].queue_free()
		#Discard_River = new_River
		#update_board_tile_positions()
		#multiplayer_Drain.rpc(client_id, Drain_Start)
#
#@rpc
#func multiplayer_Drain(client_id: int, Drain_Start: int):
	#if(multiplayer.get_unique_id() != client_id && Drain_Start >= 0):
		#var new_River: Array[Tile]
		#for i in range(Drain_Start):
			#new_River.append(Discard_River[i])
		#for i in range(Drain_Start, Discard_River.size()):
			#Discard_River[i].queue_free()
		#Discard_River = new_River
		#update_board_tile_positions()

#if(new_points > stats[1]):
	#stats[1] = new_points
#stats[0] = Score
#if(HighLevelNetworkHandler.is_multiplayer):
	#if(HighLevelNetworkHandler.server_openned):
		#players[str(1)] = Score
	#else:
		#server_get_newScore.rpc_id(1, multiplayer.get_unique_id(), Score)
#players[str(client_id)] = newScore
#stats[2] += 1

var shop_openned: bool = false

func _on_Turn_Button_pressed() -> void:
	if(PB.my_turn):
		if(PB.is_discarding()):
			$Turn_Button.text = "Cancel"
			$Turn_Button.self_modulate = Color(1, 0, 0, 1)
			
			var new_tip: String
			if(PB.progressIndex == 0):
				new_tip = "You may discard 1 Tile"
			else:
				new_tip = "You may discard up to " + str(1+PB.progressIndex) + " Tiles"
			var old_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size($Discard_Tip.text)
			$Discard_Tip.global_position.x += old_X_size.x/2
			var new_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size(new_tip)
			$Discard_Tip.size = new_X_size
			$Discard_Tip.global_position.x -= new_X_size.x/2
			$Discard_Tip.text = new_tip
			
			if(shop_openned):
				var tween = get_tree().create_tween()
				tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 1), 0.5)
		else:
			$Turn_Button.text = "End Turn"
			$Turn_Button.self_modulate = Color(1, 1, 1, 1)
			
			var tween = get_tree().create_tween()
			tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
	else:
		if(!shop_openned):
			shop_openned = true
			var tween = get_tree().create_tween()
			tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
		
		$Shop.checkButtons()
		$Shop.visible = true

func exit_shop() -> void:
	$Shop.visible = false
