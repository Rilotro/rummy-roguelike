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

var discarding: bool = false

var progressIndex: int = 0

var tiles_discarded: int = 0
var times_drained: int = 0

var my_turn: bool = false

var MS: MultiplayerSynchronizer

func _ready() -> void:
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
	
	var upper_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	var lower_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	Board_Tiles.append(upper_board)
	Board_Tiles.append(lower_board)
	
	for i in range(14):
		draw_tile()
	if((HighLevelNetworkHandler.is_multiplayer && HighLevelNetworkHandler.server_openned) || HighLevelNetworkHandler.is_singleplayer):
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
	
	if(Item.flags["Midas Touch"] > 0):
		if(Tile_Deck[0].Rarify("gold")):
			get_parent().used_PassiveItem(3)
	new_Tile.change_info(Tile_Deck[0])
	Tile_Deck.remove_at(0)
	$Deck_Counter.text = str(Tile_Deck.size())
	add_child(new_Tile)
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
		if(discarding):
			if(selected_tiles.size() >= 1+progressIndex):
				tile.post_Spread()
				return
		else:
			if(is_in_River(tile) && tiles_discarded < DT_multiplier*(1+times_drained)):
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

func update_discard_requirement():
	var new_text: String = "[font_size=12]End Turn[/font_size]"
	new_text += " [font_size=8](0"
	new_text += "/" + str(1+progressIndex) + ")[/font_size]"
	$Discard_Button/RichTextLabel.text = new_text

func is_discarding() -> bool:
	discarding = !discarding
	if(discarding):
		for tile in selected_tiles:
			tile.post_Spread()
		selected_tiles.clear()
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
	var drain_threshold: int = DT_multiplier*(1+times_drained)
	var new_text: String = "[font_size=12]Drain[/font_size] [font_size=8]("
	new_text += str(tiles_discarded) + "/"
	new_text += str(drain_threshold) + ")[/font_size]"
	$Drain_Counter/Control/RichTextLabel.text = new_text
	if(tiles_discarded >= drain_threshold):
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(0, 1, 0, 1)
		$Drain_Counter.self_modulate = Color(1, 1, 1, 1)
		$Drain_Counter/Locked.visible = false
	update_board_tile_positions()

func Add_Spread_Score() -> void:
	var new_points: int = 0
	for tile in selected_tiles:
		new_points += tile.on_spread(self)
	
	Score += new_points
	#$Score_Text.text = str(Score)
	$ProgressBar.uodateScore(Score)
	get_parent().newScore(new_points, multiplayer.get_unique_id())
	#$Shop.update_currency(currency)

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
				if(tile.getTileData().joker_id < 0 && other_tile.getTileData().joker_id < 0):
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
	var new_Spread: Spread_Info = Spread_Info.new(selected_tiles)
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

var DT_multiplier: int = 5

func Beaver():
	DT_multiplier = 3
	var drain_threshold: int = DT_multiplier*(1+times_drained)
	var new_text: String = "[font_size=12]Drain[/font_size] [font_size=8]("
	new_text += str(tiles_discarded) + "/"
	new_text += str(drain_threshold) + ")[/font_size]"
	$Drain_Counter/Control/RichTextLabel.text = new_text
	if(tiles_discarded < drain_threshold):
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(1, 0, 0, 1)
		$Drain_Counter.self_modulate = Color(0, 0, 0, 1)
		$Drain_Counter/Locked.visible = true
	else:
		$Drain_Counter/Control/RichTextLabel.self_modulate = Color(0, 1, 0, 1)
		$Drain_Counter.self_modulate = Color(1, 1, 1, 1)
		$Drain_Counter/Locked.visible = false

func Drain_River(Drain_Start: int) -> void:
	if(Drain_Start >= 0):
		var drain_threshold: int = DT_multiplier*(1+times_drained)
		tiles_discarded -= drain_threshold
		times_drained += 1
		drain_threshold += DT_multiplier
		
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
		if(HighLevelNetworkHandler.is_multiplayer):
			pass

func _on_spread() -> void:
	Spread()
	$Spread_Button.visible = false
	$Spread_Button.disabled = true

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

var button_prev_states: Array[bool]

func _on_start_turn_draw_pressed() -> void:
	$Deck_Counter/Deck_Highlight.visible = false
	$Deck_Counter/StartTurn_Draw.disabled = true
	var GameOver: bool = !(Tile_Deck.size() >= 1+progressIndex)
	get_parent().Start_Turn(GameOver)
	if(!GameOver):
		my_turn = true
		for i in range(1+progressIndex):
			draw_tile()
