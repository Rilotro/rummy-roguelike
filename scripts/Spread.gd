extends Node2D

var Spread_Rows: Array[Spread_Info]

func Spread(selected_tiles: Array[Tile]) -> void:
	var new_Spread: Spread_Info = Spread_Info.new(selected_tiles)
	Spread_Rows.append(new_Spread)
	var River_index: int = -1
	for tile_to_remove in selected_tiles:
		tile_to_remove.post_Spread()
		get_parent().remove_BoardTile(tile_to_remove)
		if(River_index == -1):
			River_index = get_parent().get_RiverTile_index(tile_to_remove)
		
		get_parent().remove_RiverTile(tile_to_remove)
		if(tile_to_remove.parentEffector == null):
			add_child(tile_to_remove)
		else:
			tile_to_remove.reparent(self)
		tile_to_remove.REparent(get_parent(), self)
	
	if(River_index >= 0):
		get_parent().Drain_River(River_index)
	
	for BRow in get_parent().get_BoardTiles():
		for tile in BRow:
			if(tile != null):
				tile.possible_Spread_highlight(false)
	
	await updateTilePos()
	await get_tree().create_timer(0.2).timeout
	
	await Add_Spread_Score(selected_tiles)

func Add_Spread_Score(selected_tiles: Array[Tile]) -> void:
	var new_points: int = 0
	for tile in selected_tiles:
		new_points += tile.on_spread()
		await get_tree().create_timer(1).timeout
	var BigScore: RichTextLabel = RichTextLabel.new()
	add_child(BigScore)
	#Vector2(Spread_Info.MIDDLE_POS, 588-40*Spread_Rows.size())
	#BigScore.global_position = final_score_pos - BigScore.custom_minimum_size/2
	BigScore.custom_minimum_size = Vector2(90, 40)
	var parentRot: float = get_parent().rotation
	var RowDistance: Vector2 = Vector2(50*(Spread_Rows.size()+1)*sin(parentRot), -40*(Spread_Rows.size()+1)*cos(parentRot))
	var XSizeDistance: Vector2 = Vector2(BigScore.custom_minimum_size.x*cos(parentRot), BigScore.custom_minimum_size.x*sin(parentRot))/2.0
	var YSizeDistance: Vector2 = Vector2(-BigScore.custom_minimum_size.y*sin(parentRot), BigScore.custom_minimum_size.y*cos(parentRot))/2.0
	BigScore.global_position = global_position + RowDistance - XSizeDistance - YSizeDistance
	for tile in selected_tiles:
		tile.UI_add_score(BigScore, new_points, selected_tiles.size())
		await get_tree().create_timer(0.3).timeout
	
	await get_tree().create_timer(1.3).timeout
	var tween = get_tree().create_tween()
	#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	tween.tween_property(BigScore, "global_position", $"../ProgressBar".global_position - XSizeDistance - YSizeDistance, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	BigScore.queue_free()
	
	get_parent().addPoints(new_points)

func updateTilePos(duration: float = 0.3):#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	var curr_pos: Vector2
	for j in range(Spread_Rows.size()):
		for i in range(Spread_Rows[j].Tiles.size()):
			curr_pos = Spread_Rows[j].get_Spread_StartPos(self) + Vector2((12.5 + 30*i)*cos(get_parent().rotation), (12.5 + 30*i)*sin(get_parent().rotation)) + Vector2(40*j*sin(get_parent().rotation), -40*j*cos(get_parent().rotation))
			if(Spread_Rows[j].Tiles[i].global_position != curr_pos && !Spread_Rows[j].Tiles[i].is_being_moved):
				Spread_Rows[j].Tiles[i].moveTile(curr_pos)
				await get_tree().create_timer(duration).timeout

func get_spread_pos(tile: Tile) -> Vector2:
	var index_y = Spread_Rows.size()-1
	if(index_y >= 0):
		var index_x: int = Spread_Rows[index_y].Tiles.find(tile)
		if(index_x >= 0):
			return Vector2(750 + 30*index_x, 628 - 40*index_y)
	return tile.orig_pos
