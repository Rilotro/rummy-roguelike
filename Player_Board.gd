extends Node2D

var Base_Tile: PackedScene = preload("res://Tile.tscn")
var Tile_Deck: Array[Tile_Info]

var selected_tiles: Array[Tile]
var mouse_timer: float = 0
var move_active: bool = false
var past_active: bool = false

var debug_added: int = 0

var Score: int = 0

var discarding: bool = false

var progressIndex: int = 0

var my_turn: bool = false

var is_MainInstance: bool = true
@onready var Board: Node2D = $Board
@onready var Spread: Node2D = $Spread
@onready var River: Node2D = $River

func becomePeerBoard() -> void:
	is_MainInstance = false
	$Spread_Button.visible = false
	$Spread_Button.disabled = true
	$Discard_Button.visible = false
	$Discard_Button.disabled = true
	$Deck_Counter.visible = false
	#$Drain_Counter.visible
	

func artificialReady() -> void:
	#$ProgressBar.owner_id = multiplayer.get_unique_id()
	$Spread_Button.visible = false
	$Spread_Button.disabled = true
	$Discard_Button.visible = false
	$Discard_Button.disabled = true
	
	var temp_Deck: Array[Tile_Info]
	for number in range(1, 14):
		for color in range(1, 5):
			temp_Deck.append(Tile_Info.new(number, color))
	for i in range(temp_Deck.size()):
		var index: int = randi_range(0, temp_Deck.size()-1)
		Tile_Deck.append(temp_Deck[index])
		temp_Deck.remove_at(index)
	Tile_Deck.insert(randi_range(0, 15), Tile_Info.new(0, 0, 0))
	$Deck_Counter.text = str(Tile_Deck.size())
	
	Draw(14)
	if((HighLevelNetworkHandler.is_multiplayer && HighLevelNetworkHandler.server_openned) || HighLevelNetworkHandler.is_singleplayer):
		$Deck_Counter/Deck_Highlight.visible = true
		$Deck_Counter/StartTurn_Draw.disabled = false

func Draw(count: int = 1) -> void:
	if(Tile_Deck.size() < count):
		return
	
	for i in range(count):
		if(Item.flags["Midas Touch"] > 0):
			if(Tile_Deck[0].Rarify("gold")):
				get_parent().used_PassiveItem(3)
		
		Board.Draw(Tile_Deck[0])
		Tile_Deck.remove_at(0)
	
	$Deck_Counter.text = str(Tile_Deck.size())

func update_selected_tiles(tile: Tile, selected: bool) -> void:
	if(tile.is_in_River()):
		for other_tile in selected_tiles:
			if(other_tile.is_in_River()):
				other_tile.post_Spread()
				selected_tiles.erase(other_tile)
				break
	
	if(selected):
		if(discarding):
			if(selected_tiles.size() >= 1+progressIndex):
				tile.post_Spread()
				return
		else:
			if(tile.is_in_River() && !River.isDrainEligible()):
				tile.post_Spread()
				return
			if(selected_tiles.is_empty()):
				$Spread_Button.visible = true
		selected_tiles.append(tile)
	else:
		selected_tiles.erase(tile)
		if(selected_tiles.is_empty()):
			if(!discarding):
				$Spread_Button.visible = false
	
	if(!discarding):
		Board.show_possible_selections(selected_tiles)
		var button_text: String = Spread_Info.check_spread_legality(selected_tiles)
		$Spread_Button.text = button_text
		if(button_text == "Spread!"):
			$Spread_Button.disabled = false
		else:
			$Spread_Button.disabled = true
	else:
		update_discard_requirement(selected_tiles.size())

func show_possible_selections() -> void:
	Board.show_possible_selections(selected_tiles)

func addPoints(newPoints: int) -> void:
	Score += newPoints
	$ProgressBar.uodateScore(Score)
	if(is_MainInstance):
		get_parent().newScore(newPoints, multiplayer.get_unique_id())

func Progress() -> void:
	if(is_MainInstance):
		progressIndex += 1

func add_tile_to_deck(tile_to_add: Tile_Info = null) -> void:
	var deck_size: int = Tile_Deck.size()
	var index: int
	if(deck_size == 0):
		index = 0
	elif(deck_size <= 20):
		index = randi_range(0, deck_size-1)
	else:
		index = randi_range(10, deck_size-11)
	
	if(tile_to_add == null):
		var joker_id: int = randi_range(-3, 2)
		var rand_num: int = randi_range(1, 13)
		var rand_col: int = randi_range(1, 4)
		tile_to_add = Tile_Info.new(rand_num, rand_col, joker_id)
	
	Tile_Deck.insert(index, tile_to_add)
	$Deck_Counter.text = str(Tile_Deck.size())

func update_discard_requirement(selectedCount: int = 0):
	var new_text: String = "[font_size=12]End Turn[/font_size]"
	new_text += " [font_size=8](" + str(selectedCount)
	new_text += "/" + str(1+progressIndex) + ")[/font_size]"
	$Discard_Button/RichTextLabel.text = new_text

func is_discarding() -> bool:
	discarding = !discarding
	if(discarding):
		for tile in selected_tiles:
			tile.post_Spread()
		selected_tiles.clear()
		show_possible_selections()
		$Spread_Button.visible = false
		$Spread_Button.disabled = true
		Tile.select_Color = Color(1, 0, 0, 1)
		
		$Discard_Button.visible = true
		$Discard_Button.disabled = false
		update_discard_requirement()
	else:
		for tile in selected_tiles:
			tile.post_Spread()
		selected_tiles.clear()
		Tile.select_Color = Color(1, 1, 0, 1)
		$Discard_Button.visible = false
		$Discard_Button.disabled = true
	
	return discarding

func update_DrainCounter() -> void:
	var new_text: String = "[font_size=15]Drain[/font_size] [font_size=10]("
	new_text += str(River.tiles_discarded) + "/"
	new_text += str(River.get_current_DrainThreshold()) + ")[/font_size]"
	$Drain_Counter/Control/RichTextLabel.text = new_text
	if(River.isDrainEligible()):
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(0, 1, 0, 1)
		$Drain_Counter.self_modulate = Color(1, 1, 1, 1)
		$Drain_Counter/Locked.visible = false
	else:
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(1, 0, 0, 1)
		$Drain_Counter.self_modulate = Color(0, 0, 0, 1)
		$Drain_Counter/Locked.visible = true

func discard() -> void:
	for tile in selected_tiles:
		remove_BoardTile(tile)
		add_RiverTile(tile)
		tile.post_Spread()
	
	update_DrainCounter()
	updateTilePos()

func add_BoardTile(tile: Tile) -> void:
	Board.add_BoardTile(tile)

func add_RiverTile(tile: Tile, OPD: bool = false) -> void:
	River.add_RiverTile(tile, !OPD)

func add_RiverPeerTiles(discarded_Tiles: Array[Tile_Info]) -> void:
	var new_tile: Tile
	for dT in discarded_Tiles:
		new_tile = Base_Tile.instantiate()
		add_child(new_tile)
		new_tile.change_info(Tile_Info.new(0, 0, 0, "", dT))
		##new_tile.global_position = otherPlayerBoard
		new_tile.global_position = Vector2(50, 320)
		add_RiverTile(new_tile, true)
	
	updateTilePos()

func get_BoardTile_index(tile: Tile) -> Vector2:
	if(tile.is_on_Board()):
		return Board.get_BoardTile_index(tile)
	return Vector2(-1, -1)

func get_RiverTile_index(tile: Tile) -> int:
	if(tile.is_in_River()):
		return River.get_RiverTile_index(tile)
	return -1

func get_BoardTiles() -> Array[Array]:
	return Board.Board_Tiles

func get_SpreadRows() -> Array[Spread_Info]:
	return Spread.Spread_Rows

func get_DrainCounter() -> Sprite2D:
	return $Drain_Counter

func remove_BoardTile(tile: Tile) -> void:
	if(tile.is_on_Board()):
		Board.remove_BoardTile(tile)

func remove_RiverTile(tile: Tile) -> void:
	if(tile.is_in_River()):
		River.remove_RiverTile(tile)

func Drain_River(Drain_Start: int):
	if(Drain_Start >= 0):
		River.Drain_River(Drain_Start)
		update_DrainCounter()
		updateTilePos()
		if(HighLevelNetworkHandler.is_multiplayer):
			get_parent().peer_Drained(multiplayer.get_unique_id(), Drain_Start)

func peer_Drained(Drain_Start: int) -> void:
	if(Drain_Start >= 0):
		River.Drain_River(Drain_Start, true)

var is_updatingPos: bool = false

func updateTilePos(duration: float = 0.3) -> void:
	is_updatingPos = true
	await Board.updateTilePos(duration)
	await River.updateTilePos(duration)
	await Spread.updateTilePos(duration)
	is_updatingPos = false

func Beaver():
	River.DT_multiplier = 3
	update_DrainCounter()

var is_spreading: bool = false

func _on_spread() -> void:
	is_spreading = true
	$Spread_Button.visible = false
	$Spread_Button.disabled = true
	if(HighLevelNetworkHandler.is_multiplayer):
		var tiles_info: Array[Tile_Info]
		for tile in selected_tiles:
			tiles_info.append(tile.getTileData())
		get_parent().peer_spread(multiplayer.get_unique_id(), tiles_info)
	await Spread.Spread(selected_tiles)
	selected_tiles.clear()
	is_spreading = false

func peerSpread(peer_SpreadTiles: Array[Tile_Info]):
	var new_tile: Tile
	#var peer_selected_tiles: Array[Tile]
	for ST in peer_SpreadTiles:
		new_tile = Base_Tile.instantiate()
		add_child(new_tile)
		new_tile.change_info(Tile_Info.new(0, 0, 0, "", ST))
		new_tile.REparent(self, self)
		selected_tiles.append(new_tile)
	
	await Spread.Spread(selected_tiles)
	selected_tiles.clear()
	
	updateTilePos()

func peer_PostSpread(peerTile: Tile_Info, Spread_Row: int, player: Node2D):
	var newTile: Tile = Base_Tile.instantiate()
	newTile.change_info(peerTile)
	
	var SR: Array[Spread_Info] = player.get_SpreadRows()
	
	add_child(newTile)
	newTile.reparent(player.Spread)
	newTile.REparent(player, player.Spread)
	newTile.global_position = global_position
	var PT_finalpos: Vector2 = SR[Spread_Row].append_postSpread(newTile)
	if(player == self):
		await player.updateTilePos(0.1)
	else:
		var tween = get_tree().create_tween()
		player.updateTilePos(0.1)
		var origRot: float = newTile.rotation
		while(player.is_updatingPos):
			tween.tween_property(newTile, "rotation", 2*PI+origRot, 0.05)
			await tween.finished
			if(player.is_updatingPos):
				newTile.rotation = origRot
				tween = get_tree().create_tween()
	
	await get_tree().create_timer(0.5).timeout
	var new_points:int = newTile.on_spread(PT_finalpos)
	await get_tree().create_timer(0.8).timeout
	
	var TMP_RTL: RichTextLabel = RichTextLabel.new()
	add_child(TMP_RTL)
	TMP_RTL.text = "0"
	TMP_RTL.visible = false
	TMP_RTL.global_position = $ProgressBar.global_position
	await newTile.UI_add_score(TMP_RTL, 0, 0)
	TMP_RTL.queue_free()
	
	addPoints(new_points)

func Activate_Draw() -> void:
	$Deck_Counter/Deck_Highlight.visible = true
	$Deck_Counter/StartTurn_Draw.disabled = false

func _on_Discard_Button_pressed() -> void:
	discard()
	$Discard_Button.visible = false
	$Discard_Button.disabled = true
	discarding = false
	my_turn = false
	
	if(HighLevelNetworkHandler.is_multiplayer):
		get_parent().peer_discarded(multiplayer.get_unique_id(), selected_tiles)
	
	get_parent().End_Turn()
	
	selected_tiles.clear()

func _on_start_turn_draw_pressed() -> void:
	$Deck_Counter/Deck_Highlight.visible = false
	$Deck_Counter/StartTurn_Draw.disabled = true
	var GameOver: bool = !(Tile_Deck.size() >= 1+progressIndex)
	get_parent().Start_Turn(GameOver)
	if(!GameOver):
		my_turn = true
		Draw(1+progressIndex)
