extends Node2D

var Base_Tile: PackedScene = preload("res://Tile.tscn")
#var Tiles: Array[Node2D]
var Tile_Deck: Array[Tile_Info]
var Board_Tiles: Array[Array]
var Discard_River: Array[Tile]
var selected_tiles: Array[Tile]
var mouse_timer: float = 0
var move_active: bool = false
var past_active: bool = false

#var River_row: int = 0

var Spread_Rows: Array[Spread_Info]
var debug_added: int = 0

var Score: int = 0

var is_discarding: bool = false

var progressIndex: int = 0

var tiles_discarded: int = 0
var times_drained: int = 0

var currency: int = 0

var stats: Array[int] = [0, 0, 0, 0]#in order: Score, Biggest Spread (Score-Wise), Times Spread, Tiles Bought

@export var players: Dictionary = {}
var my_turn: bool = false

func _ready() -> void:
	if(multiplayer.is_server() && HighLevelNetworkHandler.server_openned):
		#my_turn = true
		players[str(1)] = 0
	#else:
	$EndTurn_Button.text = "Shop"
	for id in multiplayer.get_peers():
		if(multiplayer.is_server()):
			players[str(id)] = 0
		var new_PB: Sprite2D = preload("res://ProgressBar.tscn").instantiate()
		new_PB.owner_id = id
		$MultiplayerControl.add_child(new_PB)
		match $MultiplayerControl.get_child_count():
			1:
				new_PB.global_position = Vector2(100, 320)
			2:
				new_PB.global_position = Vector2(530, 100)
	
	$ProgressBar.owner_id = multiplayer.get_unique_id()
	#$MultiplayerSpawner.multiplayer.peer_connected.connect(add_player)
	$Shop.visible = false
	$Shop.REgenerate_selections()
	
	var nex_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size($Discard_Tip.text)
	$Discard_Tip.size = nex_X_size
	$Discard_Tip.global_position.x -= nex_X_size.x/2
	#$Discard_Tip.text = "You may discard 1 Tile"
	#$Discard_Tip.modulate = Color(1, 1, 1, 0)
	
	$Spread_Button.visible = false
	$Spread_Button.disabled = true
	$Discard_Button.visible = false
	$Discard_Button.disabled = true
	#$Score_Text.text = str(0)
	
	var temp_Deck: Array[Tile_Info]
	for number in range(1, 14):
		for color in range(1, 5):
			temp_Deck.append(Tile_Info.new(number, color))
			#temp_Deck.append(Tile_Info.new(number, color))
	for i in range(temp_Deck.size()):
		var index: int = randi_range(0, temp_Deck.size()-1)
		Tile_Deck.append(temp_Deck[index])
		temp_Deck.remove_at(index)
	Tile_Deck.insert(randi_range(0, 15), Tile_Info.new(0, 0, true))
	$Deck_Counter.text = str(Tile_Deck.size())
	
	var upper_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	var lower_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	Board_Tiles.append(upper_board)
	Board_Tiles.append(lower_board)
	if(multiplayer.is_server() && HighLevelNetworkHandler.server_openned):
		$Player_Turn_Announcer.text = "It's " + HighLevelNetworkHandler.players[str(1)] + "'s Turn"
		var tween = get_tree().create_tween()
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
		#await get_tree().create_timer(1).timeout
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
	#var first_bonus: int = 0
	for i in range(14):
		draw_tile()
	if(multiplayer.is_server()):
		$Deck_Counter/Deck_Highlight.visible = true
		$Deck_Counter/StartTurn_Draw.disabled = false

func draw_tile():
	if(Tile_Deck.size() <= 0):
		return
	
	var space: bool = false
	for i in range(Board_Tiles.size()):
		if(get_actual_size_board(i) < 10):
			space = true
			break
	if(!space):
		add_board()
	
	var rand_board: int = randi_range(0, Board_Tiles.size()-1)
	#var board_full: bool = true
	while(get_actual_size_board(rand_board) >= 10):
		rand_board = randi_range(0, Board_Tiles.size()-1)
	
	var rand_place: int = randi_range(0, Board_Tiles[rand_board].size()-1)
	
	while(Board_Tiles[rand_board][rand_place] != null):
		rand_place = randi_range(0, Board_Tiles[rand_board].size()-1)
	
	var new_Tile: Tile = Base_Tile.instantiate()
	#var test_Tile: Tile = Tile.new()
	#add_child(test_Tile)
	#test_Tile.global_position = Vector2(500, 500)
	new_Tile.change_info(Tile_Deck[0])
	Tile_Deck.remove_at(0)
	$Deck_Counter.text = str(Tile_Deck.size())
	add_child(new_Tile)
	move_child(new_Tile, 10)
	Board_Tiles[rand_board][rand_place] = new_Tile
	update_board_tile_positions()

func add_board() -> void:
	#$Score_Text.global_position.y -= 40
	$ProgressBar.global_position.y -= 40
	$Spread_Button.global_position.y -= 40
	$Discard_Button.global_position.y -= 40
	
	var new_board: Sprite2D = Sprite2D.new()
	new_board.texture = CanvasTexture.new()
	new_board.scale = Vector2(300, 40)
	#var Base_Color: Color = Color(150.0/255.0, 110.0/255.0, 75.0/255.0, 1)
	var BaseR: float = 150
	var BaseG: float = 110
	var BaseB: float = 75
	var index: int = Board_Tiles.size()
	new_board.modulate = Color((BaseR - index*BaseR/5)/255, (BaseG - index*BaseG/5)/255, (BaseB - index*BaseB/5)/255, 1)
	add_child(new_board)
	move_child(new_board, 9)
	new_board.global_position = Vector2(530, 628 - 40*index)
	var new_Board_Tiles: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	Board_Tiles.append(new_Board_Tiles)

func update_selected_tiles(tile: Tile, selected: bool) -> void:
	if(is_in_River(tile)):
		for other_tile in Discard_River:
			if(other_tile.selected && other_tile != tile):
				other_tile.post_Spread()
				selected_tiles.erase(other_tile)
	
	if(selected):
		if(is_discarding):
			if(selected_tiles.size() >= 1+progressIndex):
				tile.post_Spread()
				return
		else:
			if(is_in_River(tile) && tiles_discarded < 5*(1+times_drained)):
				tile.post_Spread()
				return
			if(selected_tiles.is_empty()):
				$Spread_Button.visible = true
		selected_tiles.append(tile)
	else:
		selected_tiles.erase(tile)
		if(selected_tiles.is_empty()):
			if(!is_discarding):
				$Spread_Button.visible = false
	if(!is_discarding):
		var button_text: String = check_spread_legality()
		$Spread_Button.text = button_text
		if(button_text == "Spread!"):
			$Spread_Button.disabled = false
		else:
			$Spread_Button.disabled = true
	else:
		var new_text: String = "[font_size=12]End Turn[/font_size]"
		new_text += " [font_size=8](" + str(selected_tiles.size())
		new_text += "/" + str(1+progressIndex) + ")[/font_size]"
		$Discard_Button/RichTextLabel.text = new_text
	
	var starting_dist: float = -20 * (selected_tiles.size() - 1)
	for i in range(selected_tiles.size()):
		selected_tiles[i].distance = starting_dist
		starting_dist += 40

func get_actual_size_board(board: int) -> int:
	if(board < 0 || board >= Board_Tiles.size()):
		return -1
	
	var count: int = 0
	for tile in Board_Tiles[board]:
		if(tile != null):
			count += 1
	
	return count

func _process(_delta: float) -> void:
	if(players.size() >= multiplayer.get_peers().size()+1):
		for Peer_ProgressBoard in $MultiplayerControl.get_children():
			var acc_score: int = players[str(Peer_ProgressBoard.owner_id)]
			if(Peer_ProgressBoard.currentScore != acc_score && !Peer_ProgressBoard.is_updating):
				Peer_ProgressBoard.uodateScore(acc_score)
		
	#if(past_active != move_active):
		#past_active = move_active
	#if(Input.is_action_just_released("Left_Click")):
		#mouse_timer = 0
		#move_active = false
	#
	#if(Input.is_action_pressed("Left_Click")):
		#if(mouse_timer < 1.0):
			#mouse_timer += delta
		#else:
			#move_active = true
	
	if(Input.is_action_just_pressed("Debug_Draw")):
		$TileSelect_Screen.start_select(5)

func select_tiles(nr_tiles: int = 3):
	$TileSelect_Screen.start_select(nr_tiles)

func add_ItemSlot() -> void:
	$ItemBar.add_ItemSlot()

func buy_tile(tile_bought: Tile_Info, tile_cost: int) -> void:
	stats[3] += 1
	currency -= tile_cost
	$Shop.update_currency(currency)
	add_tile_to_deck(tile_bought)

func buy_item(item_bought: Item, cost: int) -> void:
	currency -= cost
	$Shop.update_currency(currency)
	$ItemBar.add_item(item_bought)

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
		var is_joker: bool
		var cointoss: int = randi_range(1, 100)
		var rand_num: int = randi_range(1, 13)
		var rand_col: int = randi_range(1, 4)
		if(cointoss <= 50):
			is_joker = false
		else:
			is_joker = true
			rand_num = 0
			rand_col = 0
		tile_to_add = Tile_Info.new(rand_num, rand_col, is_joker)
	
	Tile_Deck.insert(index, tile_to_add)
	$Deck_Counter.text = str(Tile_Deck.size())
	#tile_to_add = Base_Tile.instantiate()
	#tile_to_add.change_info(temp_info)
	#temp_Deck.append(Tile_Info.new(number, color))

func discard() -> void:
	var multiplayer_tiles: Array[Tile_Info]
	for tile in selected_tiles:
		multiplayer_tiles.append(tile.getTileData())
		tiles_discarded += 1
		#var tile: Node2D = selected_tiles[0]
		var on_board: bool  = false
		var index_Y: int
		var index_X: int
		for i in range(Board_Tiles.size()):
			index_X = Board_Tiles[i].find(tile)
			if(index_X >= 0):
				on_board = true
				index_Y = i
				break
		if(!on_board):
			return
		Discard_River.append(tile)
		Board_Tiles[index_Y][index_X] = null
		tile.post_Spread()
	var drain_threshold: int = 5*(1+times_drained)
	var new_text: String = "[font_size=12]Drain[/font_size] [font_size=8]("
	new_text += str(tiles_discarded) + "/"
	new_text += str(drain_threshold) + ")[/font_size]"
	$Drain_Counter/Control/RichTextLabel.text = new_text
	if(tiles_discarded >= drain_threshold):
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(0, 1, 0, 1)
		$Drain_Counter.self_modulate = Color(1, 1, 1, 1)
		$Drain_Counter/Locked.visible = false
	update_board_tile_positions()
	if(!multiplayer.is_server()):
		for tile_info in multiplayer_tiles:
			client_discard.rpc_id(1, multiplayer.get_unique_id(), inst_to_dict(tile_info))
	elif(HighLevelNetworkHandler.server_openned):
		for tile_info in multiplayer_tiles:
			multiplayer_discard.rpc(1, inst_to_dict(tile_info))

@rpc("any_peer", "call_local", "reliable")
func client_discard(client_id: int, Tile_Discarded) -> void:
	#for tile in Tiles_Discarded:
	var tile: Tile_Info = dict_to_inst(Tile_Discarded)
	var new_tile: Tile = Base_Tile.instantiate()
	new_tile.change_info(Tile_Info.new(0, 0, false, "", tile))
	add_child(new_tile)
	Discard_River.append(new_tile)
	update_board_tile_positions()
	multiplayer_discard.rpc(client_id, Tile_Discarded)

@rpc
func multiplayer_discard(client_id: int, Tile_Discarded) -> void:
	if(multiplayer.get_unique_id() != client_id):
		var tile = dict_to_inst(Tile_Discarded)
		var new_tile: Tile = Base_Tile.instantiate()
		new_tile.change_info(Tile_Info.new(0, 0, false, "", tile))
		add_child(new_tile)
		Discard_River.append(new_tile)
		update_board_tile_positions()

func Add_Spread_Score():
	var new_points: int = 0
	for tile in selected_tiles:
		new_points += tile.on_spread(self)
	if(new_points > stats[1]):
		stats[1] = new_points
	Score += new_points
	stats[0] = Score
	currency += new_points
	#$Score_Text.text = str(Score)
	$ProgressBar.uodateScore(Score)
	$Shop.update_currency(currency)
	if(multiplayer.is_server()):
		players[str(1)] = Score
	else:
		server_get_newScore.rpc_id(1, multiplayer.get_unique_id(), Score)

@rpc("any_peer", "call_local", "reliable")
func server_get_newScore(client_id: int, newScore: int) -> void:
	players[str(client_id)] = newScore

func check_spread_legality() -> String:
	if(selected_tiles.size() < 3):
		return "too few!"
	
	var same_number: bool = true
	var same_color: bool = true
	var all_diff_color: bool = true
	var ordered_tiles: Array[int]
	for tile in selected_tiles:
		ordered_tiles.append(tile.getTileData().number)
		for other_tile in selected_tiles:
			if(tile != other_tile):
				if(!tile.getTileData().joker && !other_tile.getTileData().joker):
					if(tile.getTileData().number != other_tile.getTileData().number):
						same_number = false
					
					if(!tile.getTileData().effects["rainbow"] && !other_tile.getTileData().effects["rainbow"]):
						if(tile.getTileData().color != other_tile.getTileData().color):
							same_color = false
						else:
							all_diff_color = false
	
	if(!same_color && !same_number):
		return "no pattern!"
	
	for i in range(ordered_tiles.size()):
		if(ordered_tiles[i] == 0):
			if(i > 0):
				ordered_tiles[i] = ordered_tiles[i-1]+1
			elif(i == 0):
				ordered_tiles[i] = ordered_tiles[i+1]-1
	
	if(same_color):
		ordered_tiles.sort()
		var last_val = -1
		for number in ordered_tiles:
			#if(number == 0):
				#number = last_val+1
			if(last_val != -1):
				if(number - last_val != 1 && !(last_val == 1 && ordered_tiles[ordered_tiles.size()-1] == 13)):
					return "not sequenced!"
			last_val = number
	
	if(same_number && !all_diff_color):
		return "duplicates are illegal!"
	
	return "Spread!"

func is_on_Board(tile: Tile) -> bool:
	for BRows in Board_Tiles:
		if(BRows.find(tile) >= 0):
			return true
	
	return false

func is_in_River(tile: Tile) -> bool:
	if(Discard_River.find(tile) >= 0):
		return true
	return false

func update_board_tile_positions() -> void:
	for j in range(Board_Tiles.size()):
		for i in range(Board_Tiles[j].size()):
			if(Board_Tiles[j][i] != null):
				Board_Tiles[j][i].global_position  = Vector2($Sprite2D.global_position.x - 135 + 30*i, $Sprite2D.global_position.y - 40*j)
				Board_Tiles[j][i].orig_pos = Vector2($Sprite2D.global_position.x - 135 + 30*i, $Sprite2D.global_position.y - 40*j)
	
	for k in range(Discard_River.size()):
		var river_row: int = snapped(k/10, 1)
		Discard_River[k].global_position = Vector2(400 + 30*(k - 10*river_row), 324 + 40*river_row)
	
	for j in range(Spread_Rows.size()):
		for i in range(Spread_Rows[j].Tiles.size()):
			Spread_Rows[j].Tiles[i].global_position = Vector2(750 + 30*i, 628 - 40*j)

func get_height_limit(target_pos: Vector2, current_pos: Vector2, tile: Tile) -> Vector2:
	var height_limit: float = 628 - 40 * (Board_Tiles.size() - 1)
	var length_limit_left: float = $Sprite2D.global_position.x - 135
	var length_limit_right: float = $Sprite2D.global_position.x + 135
	if(target_pos.y < height_limit):
		target_pos.y = height_limit
	elif(target_pos.y > 628):
		target_pos.y = 628
	
	if(target_pos.x < length_limit_left):
		target_pos.x = length_limit_left
	elif(target_pos.x > length_limit_right):
		target_pos.x = length_limit_right
	
	var curr_Board_pos: Vector2 = get_Board_position(tile)
	var target_Board_pos: Vector2 = curr_Board_pos
	
	if(target_pos.x > current_pos.x):
		target_Board_pos.y += 1
	if(target_pos.x < current_pos.x):
		target_Board_pos.y -= 1
	if(target_pos.y > current_pos.y):
		target_Board_pos.x -= 1
	if(target_pos.y < current_pos.y):
		target_Board_pos.x += 1
	
	if(Board_Tiles[target_Board_pos.x][target_Board_pos.y] != null):
		var temp_tile: Tile = Board_Tiles[target_Board_pos.x][target_Board_pos.y]
		Board_Tiles[target_Board_pos.x][target_Board_pos.y] = Board_Tiles[curr_Board_pos.x][curr_Board_pos.y]
		Board_Tiles[curr_Board_pos.x][curr_Board_pos.y] = temp_tile
	else:
		Board_Tiles[target_Board_pos.x][target_Board_pos.y] = Board_Tiles[curr_Board_pos.x][curr_Board_pos.y]
		Board_Tiles[curr_Board_pos.x][curr_Board_pos.y] = null
	
	update_board_tile_positions()
	
	return target_pos

func get_Board_position(tile: Tile) -> Vector2:
	var index_X: int
	
	for index_Y in range(Board_Tiles.size()):
		index_X = Board_Tiles[index_Y].find(tile)
		if(index_X >= 0):
			return Vector2(index_Y, index_X)
	
	return Vector2(-1, -1)

func get_spread_pos(tile: Tile) -> Vector2:
	var index_y = Spread_Rows.size()-1
	if(index_y >= 0):
		var index_x: int = Spread_Rows[index_y].Tiles.find(tile)
		if(index_x >= 0):
			return Vector2(750 + 30*index_x, 628 - 40*index_y)
	return tile.orig_pos

func Spread() -> void:
	#if(selected_tiles.size() > 0):
	stats[2] += 1
	var new_Spread: Spread_Info = Spread_Info.new(selected_tiles)
	#new_Spread.append_array(selected_tiles)
	Spread_Rows.append(new_Spread)
	var River_index: int = -1
	for tile_to_remove in selected_tiles:
		tile_to_remove.post_Spread()
		for BRows in Board_Tiles:
			var Board_index: int = BRows.find(tile_to_remove)
			if(Board_index >= 0):
				BRows[Board_index] = null
		if(River_index == -1):
			River_index = Discard_River.find(tile_to_remove)
		Discard_River.erase(tile_to_remove)
	if(River_index >= 0):
		Drain_River(River_index)
	
	update_board_tile_positions()
	Add_Spread_Score()
	selected_tiles.clear()

func Drain_River(Drain_Start: int) -> void:
	if(Drain_Start >= 0):
		var drain_threshold: int = 5*(1+times_drained)
		tiles_discarded -= drain_threshold
		times_drained += 1
		
		var new_text: String = "[font_size=12]Drain[/font_size] [font_size=8]("
		new_text += str(tiles_discarded) + "/"
		new_text += str(drain_threshold) + ")[/font_size]"
		$Drain_Counter/Control/RichTextLabel.text = new_text
		
		if(tiles_discarded < drain_threshold):
			$Drain_Counter/Control/RichTextLabel.self_modulate = Color(1, 0, 0, 1)
			$Drain_Counter.self_modulate = Color(0, 0, 0, 1)
			$Drain_Counter/Locked.visible = true
		
		var space: bool = false
		for i in range(Drain_Start, Discard_River.size()):
			space = false
			for j in range(Board_Tiles.size()):
				if(get_actual_size_board(j) < 10):
					space = true
					break
			if(!space):
				add_board()
			var rand_board: int = randi_range(0, Board_Tiles.size()-1)
			#var board_full: bool = true
			while(get_actual_size_board(rand_board) >= 10):
				rand_board = randi_range(0, Board_Tiles.size()-1)
			var rand_place: int = randi_range(0, Board_Tiles[rand_board].size()-1)
			
			while(Board_Tiles[rand_board][rand_place] != null):
				rand_place = randi_range(0, Board_Tiles[rand_board].size()-1)
			Board_Tiles[rand_board][rand_place] = Discard_River[i]
		var new_River: Array[Tile]
		for i in range(Drain_Start):
			new_River.append(Discard_River[i])
		Discard_River = new_River
		update_board_tile_positions()
		if(!multiplayer.is_server()):
			client_Drain.rpc_id(1, multiplayer.get_unique_id(), Drain_Start)
		elif(HighLevelNetworkHandler.server_openned):
			multiplayer_Drain.rpc(1, Drain_Start)

@rpc("any_peer", "call_local", "reliable")
func client_Drain(client_id: int, Drain_Start: int):
	if(Drain_Start >= 0):
		var new_River: Array[Tile]
		for i in range(Drain_Start):
			new_River.append(Discard_River[i])
		for i in range(Drain_Start, Discard_River.size()):
			Discard_River[i].queue_free()
		Discard_River = new_River
		update_board_tile_positions()
		multiplayer_Drain.rpc(client_id, Drain_Start)

@rpc
func multiplayer_Drain(client_id: int, Drain_Start: int):
	if(multiplayer.get_unique_id() != client_id && Drain_Start >= 0):
		var new_River: Array[Tile]
		for i in range(Drain_Start):
			new_River.append(Discard_River[i])
		for i in range(Drain_Start, Discard_River.size()):
			Discard_River[i].queue_free()
		Discard_River = new_River
		update_board_tile_positions()

func _on_spread() -> void:
	Spread()
	$Spread_Button.visible = false
	$Spread_Button.disabled = true

@rpc
func next_turn(next_client: int) -> void:
	if(multiplayer.get_unique_id() == next_client):
		$Deck_Counter/Deck_Highlight.visible = true
		$Deck_Counter/StartTurn_Draw.disabled = false

@rpc("any_peer", "call_local", "reliable")
func client_EndTurn(client_id: int):
	var client_index: int = multiplayer.get_peers().find(client_id)+1
	if(client_index >= multiplayer.get_peers().size()):
		client_index = 0
	var server_checked: bool = false
	var viable_player: bool = false
	for i in range(multiplayer.get_peers().size()+1):
		if(client_index == 0 && !server_checked):
			client_id = 1
			if(Score >= 0):
				viable_player = true
				break
			else:
				server_checked = true
				continue
		client_id = multiplayer.get_peers()[client_index]
		if(players[str(client_id)] >= 0):
			viable_player = true
			break
		else:
			client_index += 1
			if(client_index >= multiplayer.get_peers().size()):
				client_index = 0
	
	if(viable_player):
		var turn_username: String = HighLevelNetworkHandler.players[str(client_id)]
		$Player_Turn_Announcer.text = "It's " + turn_username + "'s Turn"
		var tween = get_tree().create_tween()
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 0.1)
		#await get_tree().create_timer(1).timeout
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 1), 1.5)
		tween.tween_property($Player_Turn_Announcer, "self_modulate", Color(1, 1, 1, 0), 0.25)
		
		if(client_id == 1):
			next_turn(1)
		else:
			next_turn.rpc(client_id)
	else:
		pass

func _on_EndTurn_button_pressed() -> void:
	if(my_turn):
		is_discarding = !is_discarding
		if(is_discarding):
			$EndTurn_Button.text = "Cancel"
			$EndTurn_Button.self_modulate = Color(1, 0, 0, 1)
			for tile in selected_tiles:
				tile.post_Spread()
			selected_tiles.clear()
			$Spread_Button.visible = false
			$Spread_Button.disabled = true
			Tile.select_Color = Color(1, 0, 0, 1)
			#$Shop_Button.disabled = true
			
			var new_tip: String
			if(progressIndex == 0):
				new_tip = "You may discard 1 Tile"
			else:
				new_tip = "You may discard up to " + str(1+progressIndex) + " Tiles"
			var old_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size($Discard_Tip.text)
			$Discard_Tip.global_position.x += old_X_size.x/2
			var new_X_size: Vector2 = $Discard_Tip.get_theme_font("normal_font").get_string_size(new_tip)
			$Discard_Tip.size = new_X_size
			$Discard_Tip.global_position.x -= new_X_size.x/2
			$Discard_Tip.text = new_tip
			$Discard_Button.visible = true
			$Discard_Button.disabled = false
			var new_text: String = "[font_size=12]End Turn[/font_size]"
			new_text += " [font_size=8](0"
			new_text += "/" + str(1+progressIndex) + ")[/font_size]"
			$Discard_Button/RichTextLabel.text = new_text
			
			if(shop_openned):
				var tween = get_tree().create_tween()
				tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 1), 0.5)
			#$Discard_Tip.modulate = Color(1, 1, 1, 0)
		else:
			$EndTurn_Button.text = "End Turn"
			$EndTurn_Button.self_modulate = Color(1, 1, 1, 1)
			
			for tile in selected_tiles:
				tile.post_Spread()
			selected_tiles.clear()
			#$Spread_Button.visible = false
			#$Spread_Button.disabled = true
			Tile.select_Color = Color(1, 1, 0, 1)
			#$Shop_Button.disabled = false
			$Discard_Button.visible = false
			$Discard_Button.disabled = true
			var tween = get_tree().create_tween()
			tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
	else:
		if(!shop_openned):
			shop_openned = true
			var tween = get_tree().create_tween()
			tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
		
		button_prev_states.append($EndTurn_Button.disabled)
		#button_prev_states.append($Shop_Button.disabled)
		button_prev_states.append($Spread_Button.disabled)
		button_prev_states.append($Discard_Button.disabled)
		$EndTurn_Button.disabled = true
		#$Shop_Button.disabled = true
		$Spread_Button.disabled = true
		$Discard_Button.disabled = true
		$Shop.checkButtons(currency)
		$Shop.visible = true



func _on_Discard_Button_pressed() -> void:
	$EndTurn_Button.text = "Shop"
	$EndTurn_Button.self_modulate = Color(1, 1, 1, 1)
	discard()
	$Discard_Button.visible = false
	$Discard_Button.disabled = true
	selected_tiles.clear()
	is_discarding = false
	Tile.select_Color = Color(1, 1, 0, 1)
	$Shop.REgenerate_selections()
	#$Shop_Button.disabled = false
	var tween = get_tree().create_tween()
	tween.tween_property($Discard_Tip, "modulate", Color(1, 1, 1, 0), 0.5)
	my_turn = false
	if(multiplayer.is_server() && HighLevelNetworkHandler.server_openned):
		var viable_player: int = 1
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
		if(viable_player != 1):
			next_turn.rpc(viable_player)
		elif(Score >= 0):
			next_turn(1)
	elif(!multiplayer.is_server()):
		client_EndTurn.rpc_id(1, multiplayer.get_unique_id())
	else:
		next_turn(1)

var button_prev_states: Array[bool]

func exit_shop() -> void:
	$EndTurn_Button.disabled = button_prev_states[0]
	#$Shop_Button.disabled = button_prev_states[1]
	$Spread_Button.disabled = button_prev_states[1]
	$Discard_Button.disabled = button_prev_states[2]
	$Shop.visible = false

var shop_openned: bool = false

func _on_start_turn_draw_pressed() -> void:
	$EndTurn_Button.text = "End Turn"
	$Deck_Counter/Deck_Highlight.visible = false
	$Deck_Counter/StartTurn_Draw.disabled = true
	if(Tile_Deck.size() >= 1+progressIndex):
		my_turn = true
		for i in range(1+progressIndex):
			draw_tile()
	else:
		$GameOver_Screen.GameOver(stats)
		if(multiplayer.is_server() && HighLevelNetworkHandler.server_openned):
			players[str(1)] = -Score
			var viable_player: int = 1
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
			if(viable_player != 1):
				next_turn.rpc(viable_player)
			elif(Score >= 0):
				next_turn(1)
		elif(!multiplayer.is_server()):
			server_get_newScore.rpc_id(1, multiplayer.get_unique_id(), -Score)
			client_EndTurn.rpc_id(1, multiplayer.get_unique_id())
