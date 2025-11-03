extends Node2D

var Base_Tile: PackedScene = preload("res://Tile.tscn")
var Tile_Deck: Array[Tile_Info]
var Board_Tiles: Array[Array]
var Discard_River: Array[Tile]
var selected_tiles: Array[Tile]
var mouse_timer: float = 0
var move_active: bool = false
var past_active: bool = false

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
	$ProgressBar.owner_id = multiplayer.get_unique_id()
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

var draw_delay: float = 0.0

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
	new_Tile.global_position = $Deck_Counter.global_position + $Deck_Counter.custom_minimum_size/2
	Board_Tiles[rand_board][rand_place] = new_Tile
	draw_delay += 0.1
	await get_tree().create_timer(draw_delay).timeout
	var displacement: Vector2 = Vector2(randf_range(-60, 0), randf_range(-70, 30))
	while(displacement.length() < 50):
		displacement = Vector2(randf_range(-60, 0), randf_range(-60, 30))
	await new_Tile.moveTile(new_Tile.global_position + displacement, 0.5)
	#await get_tree().create_timer(0.3).timeout
	await update_board_tile_positions(0.4)
	draw_delay -= 0.1

func add_board() -> void:
	$ProgressBar.global_position.y -= 40
	$Spread_Button.global_position.y -= 40
	$Discard_Button.global_position.y -= 40
	
	var new_board: Sprite2D = Sprite2D.new()
	new_board.texture = CanvasTexture.new()
	new_board.scale = Vector2(300, 40)
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
		show_possible_selections()
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

func show_possible_selections() -> void:
	var is_sequence: bool = false
	var common_value: int = -1
	var last_number: int = -1
	var colors: Array[int]
	var nonJoker_count: int = 0
	var nonJoker_index: int = -1
	for i in range(selected_tiles.size()):
		if(selected_tiles[selected_tiles.size()-1-i].getTileData().joker_id < 0):
			nonJoker_count += 1
			nonJoker_index = selected_tiles.size()-1-i
			if(last_number == -1):
				last_number = selected_tiles[selected_tiles.size()-1-i].getTileData().number+i
		colors.append(selected_tiles[i].getTileData().color)
	
	if(nonJoker_count > 1):
		var flag: String = check_spread_legality(true)
		if(flag.contains("number:")):
			is_sequence = false
			common_value = flag.split(":")[1].to_int()
		elif(flag.contains("color:")):
			is_sequence = true
			common_value = flag.split(":")[1].to_int()
	
	for Board in Board_Tiles:
		for other_tile in Board:
			if(other_tile != null && selected_tiles.find(other_tile) < 0):
				other_tile.possible_Spread_highlight(false)
				if(selected_tiles.size() > 0):
					if(other_tile.getTileData().joker_id >= 0):
						other_tile.possible_Spread_highlight(true)
					elif(nonJoker_count == 0):
						other_tile.possible_Spread_highlight(true)
					elif(nonJoker_count == 1):
						if(other_tile.getTileData().number == selected_tiles[nonJoker_index].getTileData().number):
							if(other_tile.getTileData().effects["rainbow"] || selected_tiles[nonJoker_index].getTileData().effects["rainbow"] || other_tile.getTileData().color != selected_tiles[nonJoker_index].getTileData().color):
								other_tile.possible_Spread_highlight(true)
						elif(other_tile.getTileData().number - last_number == 1 || (last_number == 13 && other_tile.getTileData().number == 1)):
							if(other_tile.getTileData().effects["rainbow"] || selected_tiles[nonJoker_index].getTileData().effects["rainbow"] || other_tile.getTileData().color == selected_tiles[nonJoker_index].getTileData().color):
								other_tile.possible_Spread_highlight(true)
					elif(nonJoker_count > 1):
						if(common_value > 0):
							if(is_sequence):
								if(other_tile.getTileData().color == common_value || other_tile.getTileData().effects["rainbow"]):
									if(other_tile.getTileData().number == last_number+1 || (other_tile.getTileData().number == 1 && last_number == 13)):
										other_tile.possible_Spread_highlight(true)
							else:
								if(other_tile.getTileData().number == common_value && (other_tile.getTileData().effects["rainbow"] || colors.find(other_tile.getTileData().color) < 0)):
									other_tile.possible_Spread_highlight(true)

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
	for tile in selected_tiles:
		tiles_discarded += 1
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

func add_to_River(discarded_Tiles: Array[Tile_Info]) -> void:
	var new_tile: Tile
	for dT in discarded_Tiles:
		new_tile = Base_Tile.instantiate()
		add_child(new_tile)
		new_tile.change_info(Tile_Info.new(0, 0, 0, "", dT))
		Discard_River.append(new_tile)
	update_board_tile_positions()

func Add_Spread_Score() -> void:
	var new_points: int = 0
	for tile in selected_tiles:
		new_points += tile.on_spread(self)
		await get_tree().create_timer(1).timeout
	Score += new_points
	var BigScore: RichTextLabel = RichTextLabel.new()
	add_child(BigScore)
	for tile in selected_tiles:
		tile.UI_add_score(Vector2(780, 588-40*Spread_Rows.size()), BigScore, new_points, selected_tiles.size())
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(1.3).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(BigScore, "global_position", $ProgressBar.global_position - BigScore.custom_minimum_size/2, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	BigScore.queue_free()
	
	$ProgressBar.uodateScore(Score)
	get_parent().newScore(new_points, multiplayer.get_unique_id())

func check_spread_legality(highlight: bool = false) -> String:
	if(selected_tiles.size() < 3 && !highlight):
		return "too few!"
	
	var same_number: bool = true
	var same_color: bool = true
	var all_diff_color: bool = true
	var temp_color: int = -1
	var temp_number: int = -1
	var last_number: int = -1
	var is_ordered: bool = true
	var colors: Array[int]
	
	for tile in selected_tiles:
		if(tile.getTileData().joker_id >= 0):
			colors.append(-1)
			if(last_number != -1):
				last_number += 1
				if(last_number >= 14):
					last_number = 1
		else:
			if(temp_color == -1):
				temp_color = tile.getTileData().color
				colors.append(tile.getTileData().color)
			else:
				if(tile.getTileData().effects["rainbow"]):
					colors.append(0)
				elif(tile.getTileData().color != temp_color):
					same_color = false
					if(colors.find(tile.getTileData().color) >= 0):
						all_diff_color = false
					else:
						colors.append(tile.getTileData().color)
			
			
			if(temp_number == -1):
				temp_number = tile.getTileData().number
				last_number = temp_number
			else:
				if(tile.getTileData().number - last_number != 1):
					if(!(last_number == 13 && tile.getTileData().number == 1)):
						is_ordered = false
				if(tile.getTileData().number != temp_number):
					same_number = false
				
				last_number = tile.getTileData().number
	
	if(!same_color && !same_number):
		return "no pattern!"
	
	if(same_color && !is_ordered):
		return "not sequenced!"
	
	if(same_number && !all_diff_color):
		return "duplicates are illegal!"
	
	if(same_number && !all_diff_color):
		return "duplicates are illegal!"
	
	if(highlight && selected_tiles.size() > 1):
		if(same_number):
			return "number:" + str(temp_number)
		elif(same_color):
			return "color:" + str(temp_color)
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

func update_board_tile_positions(duration: float = 0.3) -> void:
	var curr_pos: Vector2
	for j in range(Board_Tiles.size()):
		for i in range(Board_Tiles[j].size()):
			if(Board_Tiles[j][i] != null):
				curr_pos = Vector2($Sprite2D.global_position.x - 135 + 30*i, $Sprite2D.global_position.y - 40*j)
				if(Board_Tiles[j][i].global_position != curr_pos && !Board_Tiles[j][i].is_being_moved):
					Board_Tiles[j][i].moveTile(curr_pos)
					await get_tree().create_timer(duration).timeout #is_being_moved
	
	for k in range(Discard_River.size()):
		var river_row: int = snapped(k/10, 1)
		curr_pos = Vector2(400 + 30*(k - 10*river_row), 324 + 40*river_row)
		if(Discard_River[k].global_position != curr_pos && !Discard_River[k].is_being_moved):
			Discard_River[k].moveTile(curr_pos)
			await get_tree().create_timer(duration).timeout
	
	for j in range(Spread_Rows.size()):
		for i in range(Spread_Rows[j].Tiles.size()):
			curr_pos = Vector2(750 + 30*i, 628 - 40*j)
			if(Spread_Rows[j].Tiles[i].global_position != curr_pos && !Spread_Rows[j].Tiles[i].is_being_moved):
				Spread_Rows[j].Tiles[i].moveTile(curr_pos)
				await get_tree().create_timer(duration).timeout

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

var EP_HighLight: Node2D

func HighLightEndPos(curr_pos: Vector2):
	var end_pos: Vector2 = (curr_pos - Vector2(5, 28)).snapped(Vector2(30, 40)) + Vector2(5, 28)
	var Y_Bounds: Vector2 = Vector2($Sprite2D.global_position.y, $Sprite2D.global_position.y - 40*(Board_Tiles.size()-1))
	var X_Bounds: Vector2 = Vector2($Sprite2D.global_position.x + 135, $Sprite2D.global_position.x - 135)
	if(end_pos.y > Y_Bounds.x):
		end_pos.y = Y_Bounds.x
	elif(end_pos.y < Y_Bounds.y):
		end_pos.y = Y_Bounds.y
	
	if(end_pos.x > X_Bounds.x):
		end_pos.x = X_Bounds.x
	elif(end_pos.x < X_Bounds.y):
		end_pos.x = X_Bounds.y
	
	if(EP_HighLight == null):
		EP_HighLight = preload("res://scenes/sparkle_road.tscn").instantiate()
		add_child(EP_HighLight)
		EP_HighLight.change_road(end_pos, Vector2(30, 40), 0.1, get_tree().create_tween(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, end_pos, Vector2(30, 40))
		EP_HighLight.rect_offset = Vector2(24.0, 34.0)/2
	else:
		EP_HighLight.change_road(end_pos, Vector2(30, 40), 0.1)

func reposition_Tile(tile: Tile) -> void:
	var curr_pos: Vector2 = tile.global_position
	var orig_pos: Vector2
	
	var end_pos: Vector2 = (curr_pos - Vector2(5, 28)).snapped(Vector2(30, 40)) + Vector2(5, 28)
	var Y_Bounds: Vector2 = Vector2($Sprite2D.global_position.y, $Sprite2D.global_position.y - 40*(Board_Tiles.size()-1))
	var X_Bounds: Vector2 = Vector2($Sprite2D.global_position.x + 135, $Sprite2D.global_position.x - 135)
	if(end_pos.y > Y_Bounds.x):
		end_pos.y = Y_Bounds.x
	elif(end_pos.y < Y_Bounds.y):
		end_pos.y = Y_Bounds.y
	
	if(end_pos.x > X_Bounds.x):
		end_pos.x = X_Bounds.x
	elif(end_pos.x < X_Bounds.y):
		end_pos.x = X_Bounds.y
	
	var start_Board_index: Vector2
	var end_Board_index: Vector2
	var Board_Tile: Tile = null
	
	for i in range(Board_Tiles.size()):
		for j in range(Board_Tiles[i].size()):
			var Board_pos: Vector2 = Vector2($Sprite2D.global_position.x - 135 + 30*j, $Sprite2D.global_position.y - 40*i)
			if(Board_Tiles[i][j] == tile):
				orig_pos = Board_pos
				start_Board_index = Vector2(i, j)
			if(end_pos == Board_pos):
				Board_Tile = Board_Tiles[i][j]
				end_Board_index = Vector2(i, j)
	
	if(Board_Tile != null):
		Board_Tiles[start_Board_index.x][start_Board_index.y] = Board_Tiles[end_Board_index.x][end_Board_index.y]
		Board_Tiles[end_Board_index.x][end_Board_index.y] = tile
		Board_Tiles[start_Board_index.x][start_Board_index.y].moveTile(orig_pos, 0.2)
		await tile.moveTile(end_pos, 0.2)
	else:
		Board_Tiles[start_Board_index.x][start_Board_index.y] = null
		Board_Tiles[end_Board_index.x][end_Board_index.y] = tile
		await tile.moveTile(end_pos, 0.2)
	
	EP_HighLight.queue_free()

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
	
	await update_board_tile_positions()
	await get_tree().create_timer(0.2).timeout
	await Add_Spread_Score()
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
			get_parent().peer_Drained(multiplayer.get_unique_id(), Drain_Start)

func peer_Drained(Drain_pos: int) -> void:
	if(Drain_pos >= 0):
		var new_River: Array[Tile]
		for i in range(Drain_pos):
			new_River.append(Discard_River[i])
		for i in range(Drain_pos, Discard_River.size()):
			Discard_River[i].queue_free()
		Discard_River = new_River
		update_board_tile_positions()

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

func _on_start_turn_draw_pressed() -> void:
	$Deck_Counter/Deck_Highlight.visible = false
	$Deck_Counter/StartTurn_Draw.disabled = true
	var GameOver: bool = !(Tile_Deck.size() >= 1+progressIndex)
	get_parent().Start_Turn(GameOver)
	if(!GameOver):
		my_turn = true
		for i in range(1+progressIndex):
			draw_tile()
