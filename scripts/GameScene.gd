extends Node2D

class_name GameScene

var players: Array[PlayerData]
@export var playerScores: Array[int]

var stats: Array[int] = [0, 0, 0, 0]#in order: Score, Biggest Spread (Score-Wise), Times Spread, Tiles Bought

var PB: Player

var usingItem: ItemContainer = null

@export var ItemBar: GameBar
@export var TurnButton: Button
@export var BG_Obfuscator: Sprite2D
@export var GameShop: Shop
@export var tileSelectScreen: SelectScreen

static var Game: GameScene

signal StartOfTurn

func _init() -> void:
	Game = self#Vector2(600, 628) child #8
	#var PS: PackedScene = preload("res://Player_Board.tscn")
	PB = Player.new()
	add_child(PB)
	PB.position = Vector2(576, 588)
	PB.name = "PlayerObject"
	#PB = $Player_Board

func _ready() -> void:#multiplayer.get_unique_id()
	#var tween2 = create_tween()
	#tween2.tween_property(self, "self_modulate:a", 0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
	ItemBar.item_used.connect(ItemUsed)
	#PB = $Player_Board
	move_child(PB, 8)
	players.append(PlayerData.new(multiplayer.get_unique_id(), 0, PB))
	if(HighLevelNetworkHandler.is_multiplayer):
		if(HighLevelNetworkHandler.server_openned):
			playerScores.append(0)
		
		var players_added: int = 0
		for id in multiplayer.get_peers():
			var new_PB: Player = Player.new()#preload("res://Player_Board.tscn").instantiate()
			add_child(new_PB)
			new_PB.becomePeerBoard()
			players.append(PlayerData.new(id, 0, new_PB))
			if(HighLevelNetworkHandler.server_openned):
				playerScores.append(0)
			
			players_added += 1
			match players_added:
				1:
					new_PB.global_position = Vector2(50.0, 310.0)
					new_PB.rotation = deg_to_rad(90)
				2:
					new_PB.global_position = Vector2(550.0, 125.0)
					new_PB.rotation = deg_to_rad(180)
				3:
					new_PB.global_position = Vector2(1102.0, 440.0)
					new_PB.rotation = deg_to_rad(270)
	
	$Turn_Button.text = "Shop"
	GameShop.visible = false
	GameShop.REgenerate_selections()
	
	var nex_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size($Discard_Tip.text)
	$Discard_Tip.size = nex_X_size
	$Discard_Tip.global_position.x -= nex_X_size.x/2
	
	#PB.artificialReady()
	
	if(HighLevelNetworkHandler.is_multiplayer && HighLevelNetworkHandler.server_openned):
		$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(1)] + "'s Turn"
		var tween = get_tree().create_tween()
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
	#elif(HighLevelNetworkHandler.is_singleplayer):
		#PB.Activate_Draw()
	
	ItemBar.addModifier(BagOfTiles.new(self))

func _process(delta: float) -> void:
	if(usingItem != null):
		usingItem.item_info.updateWhileUsing(delta)
	
	#if(HammerSprite != null):
		#HammerSprite.global_position = get_global_mouse_position()
	if(Input.is_action_just_pressed("Debug_Draw")):
		PB.Draw()
		#if(!$TileSelect_Screen.visible && PB.my_turn && !PB.discarding):
			#$TileSelect_Screen.start_select(SelectScreen.SelectOption.BOARD_ADD_TILE, 3, {"EffectsChance": 0})

@rpc("any_peer", "call_local", "reliable")
func client_NewScore(client_id: int, newScore: int):
	for i in range(players.size()):
		if(players[i].player_id == client_id):
			players[i].Score = newScore
			playerScores[i] = newScore
			
			break

func getTurn() -> bool:
	return PB.my_turn


func Start_Turn(GameOver: bool = false) -> void:
	if(GameOver):
		if(HighLevelNetworkHandler.is_multiplayer):
			if(HighLevelNetworkHandler.server_openned):
				players[0].Score *= -1
			else:
				for player in players:
					if(player.player_id == multiplayer.get_unique_id()):
						client_NewScore.rpc_id(1, multiplayer.get_unique_id(), -player.Score)
						break
		
		End_Turn()
		$GameOver_Screen.GameOver(stats)
	else:
		$Turn_Button.text = "End Turn"
		$Turn_Button.self_modulate = Color(1, 1, 1, 1)
		#$ItemBar.StartTurn()
		StartOfTurn.emit()#multiplayer.get_unique_id()

func Next_Turn(peer_ID: int, next_peer: int = -1):
	if(HighLevelNetworkHandler.is_singleplayer || next_peer == multiplayer.get_unique_id()):
		PB.Activate_Draw()
	
	if(HighLevelNetworkHandler.is_multiplayer):
		if(HighLevelNetworkHandler.server_openned):
			if(next_peer >= 0):
				$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(next_peer)] + "'s Turn"
				var new_tween = get_tree().create_tween()
				new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
				new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
				new_tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
			else:
				$MultiplayerSynchronizer.handle_NextTurn(multiplayer.get_unique_id())
		elif(next_peer < 0):
			$MultiplayerSynchronizer.handle_NextTurn(multiplayer.get_unique_id())

func select_tiles(selectType: SelectScreen.SelectOption, selectionOptions: Vector3i, selectFlags: Dictionary):
	tileSelectScreen = SelectScreen.new(selectType, selectionOptions, selectFlags)
	add_child(tileSelectScreen)
	tileSelectScreen.position = Vector2(576, 324)
	#tileSelectScreen.position
	
	#tileSelectScreen.start_select(selectType, nr_tiles, selectFlags)
	#$TileSelect_Screen.start_select(nr_tiles, {"BoardAdd": false, "Position": DeckIndex, "Replacement": Replacement})

func newScore(newScore: int, client_ID: int):
	if(client_ID == multiplayer.get_unique_id()):
		var old_curr: int = GameShop.currency
		GameShop.update_currency(newScore)
		#var tween = 
		get_tree().create_tween().tween_method(func(x: int): $ShopCurrency.text = "Current Funds: " + str(x), old_curr, GameShop.currency, 1)
		$ShopCurrency.text = "Current Funds: " + str(GameShop.currency)
		#$ShopCurrency.global_position.x = $Turn_Button.global_position.x + $Turn_Button.size.x/2.0 - $ShopCurrency.size.x/2.0
		if(HighLevelNetworkHandler.is_multiplayer):
			$MultiplayerSynchronizer.handle_newScore(newScore, client_ID)

func addShopUses() -> void:
	GameShop.addShopUses()

var emitting: bool = false

func ItemUsed(peer_id: int)-> void:
	if(peer_id == multiplayer.get_unique_id()):
		$MultiplayerSynchronizer.handle_ItemUsed(peer_id)
	elif(!emitting):
		emitting = true
		$ItemBar.item_used.emit(peer_id)
		emitting = false

#var HammerSprite: Sprite2D

func startIteamUse(item: ItemContainer):
	usingItem = item
	
	if(item.item_info.target == Item.ItemTarget.VIABLE_BOARD_TILE):#Item.hasSpecialHighlight.find(item.item_info.id) >= 0):
		PB.show_possible_selections(true)

func endItemUse() -> void:
	var tempItem: ItemContainer = usingItem
	usingItem = null
	
	$Turn_Button.disabled = false
	$Turn_Button.text = "End Turn"
	
	if(tempItem.item_info.target == Item.ItemTarget.VIABLE_BOARD_TILE):#Item.hasSpecialHighlight.find(item.item_info.id) >= 0):
		PB.show_possible_selections(true)
	
	ItemBar.endItemUse(tempItem)

func addItemBarUses() -> void:
	$ItemBar.addItemBarUses()

func used_PassiveItem(item_ID: int):
	$ItemBar.used_PassiveItem(item_ID)

func add_ItemSlot() -> void:
	$ItemBar.add_ItemSlot()

func buy_tile(tile_bought: Tile_Info, animationTile: TileContainer = null) -> void:
	stats[3] += 1
	PB.add_tile_to_deck(tile_bought, -1, animationTile)

func buy_item(item_bought: Item) -> void:
	ItemBar.add_item(item_bought)

func Gain_Freebie(freebies: int = 1) -> void:
	GameShop.Gain_Freebie(freebies)

var Base_Tile: PackedScene = preload("res://Tile.tscn")

func peer_discarded(peer_id: int, peer_DT: Array):
	if(peer_id == multiplayer.get_unique_id()):
		$MultiplayerSynchronizer.handle_discard(peer_id, peer_DT)
	else:
		var deserialized_tile: Array[Tile_Info]
		for serialezed_tile in peer_DT:
			deserialized_tile.append(dict_to_inst(serialezed_tile))
		PB.add_RiverPeerTiles(deserialized_tile)
		for player in players:
			if(player.player_id == peer_id):
				player.player_Node.River.tiles_discarded += deserialized_tile.size()
				player.player_Node.update_DrainCounter()

func peer_spread(peer_id: int, spread_tiles: Array) -> void:
	if(peer_id == multiplayer.get_unique_id()):
		$MultiplayerSynchronizer.handle_spread(peer_id, spread_tiles)
	else:
		var deserialized_tile: Array[Tile_Info]
		for serialezed_tile in spread_tiles:
			deserialized_tile.append(dict_to_inst(serialezed_tile))
		
		for player in players:
			if(player.player_id == peer_id):
				player.player_Node.peerSpread(deserialized_tile)

func peer_PostSpread(tile_spread: Tile_Info, Spread_Row: int, PlayerBoard, peer_id: int) -> void:
	if(peer_id == multiplayer.get_unique_id()):
		for i in range(players.size()):
			if(players[i].player_Node == PlayerBoard):
				$MultiplayerSynchronizer.handle_PostSpread(peer_id, tile_spread, players[i].player_id, Spread_Row)
				break
	else:
		var OPlayer: Node2D
		var IPlayer: Node2D
		for player in players:
			if(player.player_id == peer_id):
				OPlayer = player.player_Node
			if(player.player_id == PlayerBoard):
				IPlayer = player.player_Node
				#for i in range(players.size()):
					#if(players[i].player_id == PlayerBoard):#---------------------------------------------------------------------
						#
						#break
		OPlayer.peer_PostSpread(tile_spread, Spread_Row, IPlayer)

func peer_Drained(peer_id: int, Drain_pos: int) -> void:
	if(peer_id == multiplayer.get_unique_id()):
		$MultiplayerSynchronizer.handle_Drain(peer_id, Drain_pos)
	else:
		PB.peer_Drained(Drain_pos)
		for player in players:
			if(player.player_id == peer_id):
				player.player_Node.River.peer_Drained()
				player.player_Node.update_DrainCounter()

signal EndOfRound

func End_Turn():
	TurnButton.text = "Shop"
	TurnButton.self_modulate = Color(1, 1, 1, 1)
	Tile.select_Color = Color(1, 1, 0, 1)
	GameShop.REgenerate_selections()
	
	var tween = get_tree().create_tween()
	tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
	
	EndOfRound.emit()
	
	Next_Turn(multiplayer.get_unique_id())

var shop_openned: bool = false

func _on_Turn_Button_pressed() -> void:
	var itemCanBeUsedInShop: bool = false
	if(usingItem != null && usingItem.item_info.target == Item.ItemTarget.ANY_HIGHLIGHT):
		itemCanBeUsedInShop = true
	
	if(PB.my_turn && !itemCanBeUsedInShop):# && !Item.is_HammerTime
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
		
		GameShop.checkButtons()
		GameShop.visible = true

func exit_shop() -> void:
	GameShop.visible = false
