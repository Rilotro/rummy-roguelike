extends Node2D

var Board_Tiles: Array[Array]
var Base_Tile: PackedScene = preload("res://Tile.tscn")
var draw_delay: float = 0.0

func _ready() -> void:
	var upper_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	var lower_board: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	Board_Tiles.append(upper_board)
	Board_Tiles.append(lower_board)

func add_BoardTile(newTile: Tile) -> void:
	var space: bool = false
	for i in range(Board_Tiles.size()):
		if(get_child(i).get_child_count() < 10):
			space = true
			break
	if(!space):
		add_board()
	
	var rand_board: int = randi_range(0, Board_Tiles.size()-1)
	while(get_child(rand_board).get_child_count() >= 10):
		rand_board = randi_range(0, Board_Tiles.size()-1)
	
	var rand_place: int = randi_range(0, Board_Tiles[rand_board].size()-1)
	
	while(Board_Tiles[rand_board][rand_place] != null):
		rand_place = randi_range(0, Board_Tiles[rand_board].size()-1)
	
	if(newTile.parentEffector == null):
		get_child(rand_board).add_child(newTile)
	else:
		newTile.reparent(get_child(rand_board))
	
	newTile.REparent(get_parent(), self)
	Board_Tiles[rand_board][rand_place] = newTile
	

func Draw(TI: Tile_Info):
	var newTile: Tile = Base_Tile.instantiate()
	
	var displacement: Vector2 = Vector2(randf_range(-60, 0), randf_range(-70, 30))
	while(displacement.length() < 50):
		displacement = Vector2(randf_range(-60, 0), randf_range(-60, 30))
	
	add_BoardTile(newTile)
	newTile.change_info(TI)
	newTile.global_position = $"../Deck_Counter".global_position + $"../Deck_Counter".custom_minimum_size/2
	
	draw_delay += 0.1
	await get_tree().create_timer(draw_delay).timeout
	await newTile.moveTile(newTile.global_position + displacement, 0.5)
	await updateTilePos(0.4)
	draw_delay -= 0.1

func add_board() -> void:
	$"../ProgressBar".global_position.y -= 40
	$"../Spread_Button".global_position.y -= 40
	$"../Discard_Button".global_position.y -= 40
	
	var new_board: Sprite2D = Sprite2D.new()
	new_board.texture = CanvasTexture.new()
	new_board.region_enabled = true
	new_board.region_rect = Rect2(Vector2(), Vector2(300, 40))
	var BaseR: float = 150
	var BaseG: float = 110
	var BaseB: float = 75
	var index: int = Board_Tiles.size()
	new_board.self_modulate = Color((BaseR - index*BaseR/5)/255, (BaseG - index*BaseG/5)/255, (BaseB - index*BaseB/5)/255, 1)
	add_child(new_board)
	new_board.global_position = global_position + Vector2(0, -40*index)
	var new_Board_Tiles: Array[Tile] = [null, null, null, null, null, null, null, null, null, null]
	Board_Tiles.append(new_Board_Tiles)

func updateTilePos(duration: float = 0.3) -> void:
	var curr_pos: Vector2
	for j in range(Board_Tiles.size()):
		for i in range(Board_Tiles[j].size()):
			if(Board_Tiles[j][i] != null):
				curr_pos = Vector2(global_position.x - 135 + 30*i, get_child(j).global_position.y)
				if(Board_Tiles[j][i].global_position != curr_pos && !Board_Tiles[j][i].is_being_moved):
					Board_Tiles[j][i].moveTile(curr_pos)
					await get_tree().create_timer(duration).timeout

func show_possible_selections(selected_tiles: Array[Tile], MonkeyPaw: bool = false, MidasTouch: bool = false) -> void:
	var is_sequence: bool = false
	var common_value: int = -1
	var last_number: int = -1
	var colors: Array[int]
	var nonJoker_count: int = 0
	var nonJoker_index: int = -1
	var EOS_reached: bool = false
	
	for i in range(selected_tiles.size()):
		if(selected_tiles[selected_tiles.size()-1-i].getTileData().joker_id < 0):
			nonJoker_count += 1
			nonJoker_index = selected_tiles.size()-1-i
			if(last_number == -1):
				last_number = selected_tiles[selected_tiles.size()-1-i].getTileData().number+i
				if(last_number >= 14):
					last_number = 1
					EOS_reached = true
				
		elif(last_number == 1):
			EOS_reached = true
		colors.append(selected_tiles[i].getTileData().color)
	
	if(nonJoker_count > 1):
		var flag: String = Spread_Info.check_spread_legality(selected_tiles, true)
		if(flag.contains("number:")):
			is_sequence = false
			common_value = flag.split(":")[1].to_int()
		elif(flag.contains("color:")):
			is_sequence = true
			common_value = flag.split(":")[1].to_int()
			if(last_number == 1):
				EOS_reached = true
	
	for Board in Board_Tiles:
		for other_tile in Board:
			if(other_tile != null && selected_tiles.find(other_tile) < 0):
				other_tile.possible_Spread_highlight(false)
				if(MonkeyPaw && other_tile.getTileData().joker_id < 0 && other_tile.getTileData().rarity != "porcelain" && other_tile.getTileData().rarity != ""):
					other_tile.possible_Spread_highlight(true)
				
				if(MidasTouch && other_tile.getTileData().joker_id < 0 && other_tile.getTileData().rarity != "gold"):
					other_tile.possible_Spread_highlight(true)
				
				if(!MonkeyPaw && !MidasTouch && selected_tiles.size() > 0):
					if(nonJoker_count == 0):
						other_tile.possible_Spread_highlight(true)
					elif(!EOS_reached || colors.size() < 4):
						if(nonJoker_count == 1):
							if(other_tile.getTileData().joker_id >= 0):
								if(!EOS_reached || colors.size() < 4):
									other_tile.possible_Spread_highlight(true)
							elif(other_tile.getTileData().number == selected_tiles[nonJoker_index].getTileData().number):
								if(colors.size() < 4 && other_tile.getTileData().color != selected_tiles[nonJoker_index].getTileData().color):
									other_tile.possible_Spread_highlight(true)
							elif(!EOS_reached && (other_tile.getTileData().number - last_number == 1 || (last_number == 13 && other_tile.getTileData().number == 1))):
								if(other_tile.getTileData().effects["rainbow"] || selected_tiles[nonJoker_index].getTileData().effects["rainbow"] || other_tile.getTileData().color == selected_tiles[nonJoker_index].getTileData().color):
									other_tile.possible_Spread_highlight(true)
						elif(nonJoker_count > 1):
							if(common_value > 0):
								if(is_sequence):
									if(other_tile.getTileData().joker_id >= 0 && !EOS_reached):
										other_tile.possible_Spread_highlight(true)
									elif(other_tile.getTileData().color == common_value || other_tile.getTileData().effects["rainbow"]):
										if(!EOS_reached && (other_tile.getTileData().number == last_number+1 || (other_tile.getTileData().number == 1 && last_number == 13))):
											other_tile.possible_Spread_highlight(true)
								else:
									if(other_tile.getTileData().joker_id >= 0 && colors.size() < 4):
										other_tile.possible_Spread_highlight(true)
									elif(other_tile.getTileData().number == common_value && colors.size() < 4 && (other_tile.getTileData().effects["rainbow"] || colors.find(other_tile.getTileData().color) < 0)):
										other_tile.possible_Spread_highlight(true)

func get_actual_size_board(board: int) -> int:
	if(board < 0 || board >= Board_Tiles.size()):
		return -1
	
	var count: int = 0
	for tile in Board_Tiles[board]:
		if(tile != null):
			count += 1
	
	return count

var EP_HighLight: Node2D

func HighLightEndPos(tile: Tile):
	var curr_pos = tile.global_position
	var end_pos: Vector2 = (curr_pos - Vector2(15, 28)).snapped(Vector2(30, 40)) + Vector2(15, 28)
	var Y_Bounds: Vector2 = Vector2(global_position.y, global_position.y - 40*(Board_Tiles.size()-1))
	var X_Bounds: Vector2 = Vector2(global_position.x + 135, global_position.x - 135)
	var HL_size: Vector2 = Vector2(30, 40)
	var HL_onSpread: int = -1
	#var GamePlayers: Array[Node2D]
	#var GameSpreads: Array[Node2D]
	var parentRot: float
	var S: Node2D
	
	
	for player in get_parent().get_parent().players:
		S = player.player_Node.Spread
		parentRot = player.player_Node.rotation
		
		#var P1: Vector2 = S.global_position + Vector2(-100*cos(parentRot), -100*sin(parentRot))
		#var P2: Vector2 = S.global_position + Vector2(100*cos(parentRot), 100*sin(parentRot))
		
		#var D1: float = abs(cos(parentRot-PI/2)*(P1.y-curr_pos.y) - sin(parentRot-PI/2)*(P1.x-curr_pos.x))
		#var D2: float = abs(cos(parentRot-PI/2)*(P2.y-curr_pos.y) - sin(parentRot-PI/2)*(P2.x-curr_pos.x))
		
		#600.0   628.0
		#50.0   310.0
		
		#D1 <= 200.0 && D2 <= 200.0
		
		if(S.Spread_Rows.size() > 0 && S.mouse_inside):
			var row_LL: Vector2 = S.global_position + Vector2(-17.5*sin(parentRot), 17.5*cos(parentRot))
			var row_UL: Vector2 = S.global_position + Vector2(-17.5*sin(parentRot), 17.5*cos(parentRot))
			for i in range(S.Spread_Rows.size()):
				row_LL = row_UL
				row_UL += Vector2(35.0*sin(parentRot), -35.0*cos(parentRot))
				
				var row_D1: float = abs(cos(parentRot)*(row_LL.y-curr_pos.y) - sin(parentRot)*(row_LL.x-curr_pos.x))
				var row_D2: float = abs(cos(parentRot)*(row_UL.y-curr_pos.y) - sin(parentRot)*(row_UL.x-curr_pos.x))
				
				#var row_Y: float = $"../Spread".global_position.y - 40*i
				end_pos = (row_LL + row_UL)/2.0
				if(i >= S.Spread_Rows.size()-1):
					#if(end_pos.y <= row_Y):
					#end_pos.y = row_Y
					HL_size = S.Spread_Rows[i].get_SpreadSize(S) + Vector2(40*abs(sin(parentRot)), 40*abs(cos(parentRot)))#Vector2(S.Spread_Rows[i].Tiles.size()*30*abs(cos(parentRot)), S.Spread_Rows[i].Tiles.size()*30*abs(sin(parentRot))) + Vector2(40*abs(sin(parentRot)), 40*abs(cos(parentRot)))
					HL_onSpread = i
				elif(row_D1 <= 40 && row_D2 <= 40):
					#end_pos.y = row_Y
					HL_size = S.Spread_Rows[i].get_SpreadSize(S) + Vector2(40*abs(sin(parentRot)), 40*abs(cos(parentRot)))#Vector2(S.Spread_Rows[i].Tiles.size()*30*abs(cos(parentRot)), S.Spread_Rows[i].Tiles.size()*30*abs(sin(parentRot))) + Vector2(40*abs(sin(parentRot)), 40*abs(cos(parentRot)))
					HL_onSpread = i
					break
				
				row_UL += Vector2(5.0*sin(parentRot), -5.0*cos(parentRot))
			if(HL_onSpread >= 0):
				break
	
	if(HL_onSpread == -1):
		if(end_pos.x > X_Bounds.x):
			end_pos.x = X_Bounds.x
		elif(end_pos.x < X_Bounds.y):
			end_pos.x = X_Bounds.y
		if(HL_onSpread == -1):
			if(end_pos.y > Y_Bounds.x):
				end_pos.y = Y_Bounds.x
			elif(end_pos.y < Y_Bounds.y):
				end_pos.y = Y_Bounds.y
	
	if(EP_HighLight == null):
		EP_HighLight = preload("res://scenes/sparkle_road.tscn").instantiate()
		add_child(EP_HighLight)
		#EP_HighLight.change_polarity(true)
		EP_HighLight.change_road(end_pos, HL_size, 0.0)
		if(HL_onSpread == -1):
			EP_HighLight.change_polarity(true)
			EP_HighLight.rect_offset = Vector2(24.0, 34.0)/2
		else:
			if(S.Spread_Rows[HL_onSpread].is_postSpread_Eligible(tile, S == get_parent().Spread)):
				EP_HighLight.change_polarity(true)
			else:
				EP_HighLight.change_polarity(false)
			
			EP_HighLight.rect_offset = (HL_size - Vector2(6, 6))/2.0
			#Vector2(SR[HL_onSpread].Tiles.size()*30 - 6, 34.0)/2
			#HL_size = Vector2(SR[i].Tiles.size()*30*abs(cos(parentRot)), SR[i].Tiles.size()*30*abs(sin(parentRot))) + Vector2(40*abs(sin(parentRot)), 40*abs(cos(parentRot)))
	else:
		EP_HighLight.change_road(end_pos, HL_size, 0.1)
		if(HL_onSpread == -1):
			EP_HighLight.change_polarity(true)
			EP_HighLight.rect_offset = Vector2(24.0, 34.0)/2
		else:
			if(S.Spread_Rows[HL_onSpread].is_postSpread_Eligible(tile, S == get_parent().Spread)):
				EP_HighLight.change_polarity(true)
			else:
				EP_HighLight.change_polarity(false)
			
			#EP_HighLight.rect_offset = Vector2(SR[HL_onSpread].Tiles.size()*30 - 6, 34.0)/2
			EP_HighLight.rect_offset = (HL_size - Vector2(6, 6))/2.0

func reposition_Tile(tile: Tile) -> void:
	var curr_pos: Vector2 = tile.global_position
	var orig_pos: Vector2
	var parentRot: float
	var end_pos: Vector2 = (curr_pos - Vector2(15, 28)).snapped(Vector2(30, 40)) + Vector2(15, 28)
	var Spread_end_pos: Vector2
	var Y_Bounds: Vector2 = Vector2(global_position.y, global_position.y - 40*(Board_Tiles.size()-1))
	var X_Bounds: Vector2 = Vector2(global_position.x + 135, global_position.x - 135)
	var HL_onSpread: int = -1
	var S: Node2D
	
	for player in get_parent().get_parent().players:
		S = player.player_Node.Spread
		parentRot = player.player_Node.rotation
		if(S.Spread_Rows.size() > 0 && S.mouse_inside):
			var row_LL: Vector2 = S.global_position + Vector2(-17.5*sin(parentRot), 17.5*cos(parentRot))
			var row_UL: Vector2 = S.global_position + Vector2(-17.5*sin(parentRot), 17.5*cos(parentRot))
			for i in range(S.Spread_Rows.size()):
				row_LL = row_UL
				row_UL += Vector2(35.0*sin(parentRot), -35.0*cos(parentRot))
				
				var row_D1: float = abs(cos(parentRot)*(row_LL.y-curr_pos.y) - sin(parentRot)*(row_LL.x-curr_pos.x))
				var row_D2: float = abs(cos(parentRot)*(row_UL.y-curr_pos.y) - sin(parentRot)*(row_UL.x-curr_pos.x))
				
				if(i >= S.Spread_Rows.size()-1):
					HL_onSpread = i
				elif(row_D1 <= 40 && row_D2 <= 40):
					HL_onSpread = i
					break
				
				row_UL += Vector2(5.0*sin(parentRot), -5.0*cos(parentRot))
			if(HL_onSpread >= 0):
				break
	
	if(end_pos.x > X_Bounds.x):
		end_pos.x = X_Bounds.x
	elif(end_pos.x < X_Bounds.y):
		end_pos.x = X_Bounds.y
	
	if(end_pos.y > Y_Bounds.x):
		end_pos.y = Y_Bounds.x
	elif(end_pos.y < Y_Bounds.y):
		end_pos.y = Y_Bounds.y
	
	var start_Board_index: Vector2
	var end_Board_index: Vector2
	var Board_Tile: Tile = null
	
	for i in range(Board_Tiles.size()):
		for j in range(Board_Tiles[i].size()):
			var Board_pos: Vector2 = Vector2(global_position.x - 135 + 30*j, global_position.y - 40*i)
			if(Board_Tiles[i][j] == tile):
				orig_pos = Board_pos
				start_Board_index = Vector2(i, j)
			if(end_pos == Board_pos):
				Board_Tile = Board_Tiles[i][j]
				end_Board_index = Vector2(i, j)
	
	var check_eli: bool = false
	if(HL_onSpread != -1):
		check_eli = S.Spread_Rows[HL_onSpread].is_postSpread_Eligible(tile, S == get_parent().Spread)
	
	if(HL_onSpread == -1 || !check_eli):
		if(Board_Tile != null):
			Board_Tiles[start_Board_index.x][start_Board_index.y] = Board_Tiles[end_Board_index.x][end_Board_index.y]
			Board_Tiles[end_Board_index.x][end_Board_index.y] = tile
			Board_Tiles[start_Board_index.x][start_Board_index.y].moveTile(orig_pos, 0.2)
			if(end_Board_index != start_Board_index):
				Board_Tiles[start_Board_index.x][start_Board_index.y].reparent(get_child(start_Board_index.x))
				Board_Tiles[end_Board_index.x][end_Board_index.y].reparent(get_child(end_Board_index.x))
			await tile.moveTile(end_pos, 0.2)
		else:
			Board_Tiles[start_Board_index.x][start_Board_index.y] = null
			Board_Tiles[end_Board_index.x][end_Board_index.y] = tile
			if(end_Board_index != start_Board_index):
				Board_Tiles[end_Board_index.x][end_Board_index.y].reparent(get_child(end_Board_index.x))
			await tile.moveTile(end_pos, 0.2)
		
		EP_HighLight.queue_free()
	else:
		Board_Tiles[start_Board_index.x][start_Board_index.y] = null
		get_parent().get_parent().peer_PostSpread(tile.getTileData(), HL_onSpread, S.get_parent(), multiplayer.get_unique_id())
		tile.reparent(S)
		tile.REparent(S.get_parent(), S)
		var PT_finalpos: Vector2 = S.Spread_Rows[HL_onSpread].append_postSpread(tile)
		if(S.get_parent() == get_parent()):
			await S.get_parent().updateTilePos(0.1)
		else:
			S.get_parent().updateTilePos(0.1)
			var origRot: float = tile.rotation
			while(S.get_parent().is_updatingPos):
				var tween = get_tree().create_tween()
				tween.tween_property(tile, "rotation", 2*PI+origRot, 0.05)
				await tween.finished
				if(S.get_parent().is_updatingPos):
					tile.rotation = origRot
					tween = get_tree().create_tween()
		
		EP_HighLight.queue_free()
		await get_tree().create_timer(0.5).timeout
		var new_points: int = tile.on_spread(PT_finalpos, S.Spread_Rows[HL_onSpread])
		await get_tree().create_timer(0.8).timeout
		
		var TMP_RTL: RichTextLabel = RichTextLabel.new()
		add_child(TMP_RTL)
		TMP_RTL.text = "0"
		TMP_RTL.visible = false
		TMP_RTL.global_position = $"../ProgressBar".global_position
		await tile.UI_add_score(TMP_RTL, 0, 0)
		TMP_RTL.queue_free()
		
		get_parent().addPoints(new_points)

func remove_BoardTile( tile: Tile) -> void:
	var tileIndex: Vector2 = get_BoardTile_index(tile)
	if(tileIndex.x >= 0 && tileIndex.y >= 0):
		Board_Tiles[tileIndex.x][tileIndex.y] = null

func get_BoardTile_index(tile: Tile) -> Vector2:
	var index_X: int
	
	for index_Y in range(Board_Tiles.size()):
		index_X = Board_Tiles[index_Y].find(tile)
		if(index_X >= 0):
			return Vector2(index_Y, index_X)
	
	return Vector2(-1, -1)
