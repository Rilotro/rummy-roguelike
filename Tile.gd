extends Node2D

class_name Tile

var mouse_entered: bool = false
var selected: bool = false
var is_moving: bool  = false
#var mouse_distance: Vector2
var distance: float = 0
var LC_timer: float = 0.0

var mouse_still_inside: bool = false

var endPos_Highlight: PackedScene = preload("res://endPos_Highlight.tscn")
var curr_EPH: Sprite2D

static var select_Color: Color = Color(1, 1, 0, 1)

func change_info(new_info: Tile_Info):
	$Body.change_info(new_info)

func _process(delta: float) -> void:
	if(Input.is_action_just_released("Left_Click")):
		if(LC_timer >= 0.2):
			LC_timer = 0.0
		elif(mouse_still_inside):
			if(get_parent().my_turn && get_parent().is_on_Board(self)):
				selected = !selected
				possible_Spread_highlight(false)
				get_parent().update_selected_tiles(self, selected)
				if(selected):
					$Body.changeHighLight(select_Color)
				elif(!$Body.Spread_highligh):
					$Body.changeHighLight(Color(0, 0, 0, 1))
			elif(get_parent().my_turn && get_parent().is_in_River(self) && !get_parent().discarding):
				selected = !selected
				get_parent().update_selected_tiles(self, selected)
				if(selected):
					$Body.changeHighLight(Color(0, 1, 0, 1))
				else:
					$Body.changeHighLight(Color(0, 0, 0, 1))
	
	if(Input.is_action_just_pressed("Left_Click") && mouse_entered):
		mouse_still_inside = true
		LC_timer = 0.0
	
	if(Input.is_action_pressed("Left_Click")):
		if(mouse_still_inside):
			if(mouse_entered):
				if(LC_timer < 0.2 && get_parent().is_on_Board(self)):
					LC_timer += delta
					if(LC_timer >= 0.2):
						$Body._on_control_mouse_exited()
			else:
				mouse_still_inside = false
		if(LC_timer >= 0.2):
			mouse_still_inside = false
			tile_move()

func possible_Spread_highlight(activate: bool) -> void:
	$Body.possible_Spread_highlight(activate)

func tile_move():
	var target_pos: Vector2 = (get_global_mouse_position() - Vector2(5, 28)).snapped(Vector2(30, 40)) + Vector2(5, 28)
	if(target_pos != global_position):
		target_pos = get_parent().get_height_limit(target_pos, global_position, self)

var PointText: RichTextLabel
var SR: Node2D

func on_spread(Board: Node2D) -> int:
	var TD: Tile_Info = $Body.Tile_Data
	var final_points: int = TD.points
	if(TD.joker_id < 0):
		if(TD.effects["duplicate"]):
			var modified_effects: Dictionary = TD.effects
			modified_effects["duplicate"] = false
			Board.add_tile_to_deck(Tile_Info.new(TD.number, TD.color, TD.joker_id, TD.rarity, null, modified_effects))
	else:
		match TD.joker_id:
			1:
				final_points += 10*(Board.selected_tiles.size()-1)
			2:
				Board.get_parent().Gain_Freebie(1)
	
	SR = preload("res://scenes/sparkle_road.tscn").instantiate()
	var EW: Sprite2D = preload("res://scenes/Explosion_Wave.tscn").instantiate()
	add_child(EW)
	add_child(SR)
	
	PointText = RichTextLabel.new()
	add_child(PointText)
	PointText.custom_minimum_size = Vector2(25, 40)
	PointText.fit_content = true
	PointText.scroll_active = false
	PointText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PointText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	PointText.modulate = Color(1, 1, 0, 1)
	var fontSize: int = 16
	match str(final_points).length():
		1:
			fontSize = 16
		2:
			fontSize = 14
		3:
			fontSize = 10
	PointText.add_theme_font_size_override("normal_font_size", fontSize)
	PointText.text = "+" + str(final_points)
	PointText.global_position -= $Body.acc_size()/2
	move_child(PointText, 0)
	move_child(SR, 0)
	var tween = get_tree().create_tween()
	SR.change_road(global_position, Vector2(30, 42), 0.3, tween, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.parallel().tween_property(PointText, "global_position:y", PointText.global_position.y-40, 0.75).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	return final_points

func UI_add_score(final_score_pos: Vector2, BigScore: RichTextLabel, BigPoints: int, Spread_size: int) -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel()
	SR.HB_density = 3
	SR.LB_density = -2
	SR.change_road(final_score_pos, PointText.get_theme_font("normal_font").get_string_size("+5000"), 1, tween, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.tween_property(PointText, "global_position", final_score_pos - PointText.custom_minimum_size/2, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	if(BigScore.text == ""):
		BigScore.custom_minimum_size = Vector2(90, 40)
		BigScore.fit_content = true
		BigScore.scroll_active = false
		BigScore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		BigScore.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		BigScore.modulate = Color(1, 1, 0, 1)
		BigScore.add_theme_font_size_override("normal_font_size", 16)
		BigScore.text = "+0"
		BigScore.global_position = final_score_pos - BigScore.custom_minimum_size/2
		
		#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		await tween.finished
		var BS_SR: Node2D = preload("res://scenes/sparkle_road.tscn").instantiate()
		BigScore.add_child(BS_SR)
		BS_SR.change_road(BigScore.global_position+BigScore.custom_minimum_size/2, BigScore.custom_minimum_size, 0.01, get_tree().create_tween(), Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, BigScore.global_position, BigScore.custom_minimum_size)
		BS_SR.HB_density = 2
		BS_SR.LB_density = -2
		PointText.queue_free()
		SR.queue_free()
		tween = get_tree().create_tween()
		tween.set_parallel(false)
		tween.tween_method(update_BigScore.bind(BigScore), 0, BigPoints, 0.5 + 0.3*(Spread_size-1))
	else:
		await tween.finished
		PointText.queue_free()
		SR.queue_free()
	#return BigScore

func update_BigScore(BigPoints:int, BigScore: RichTextLabel):
	BigScore.text = "+" + str(BigPoints)

var is_being_moved: bool = false

func moveTile(endPos: Vector2, duration: float = 0.5) -> void:
	is_being_moved = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", endPos, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	is_being_moved = false

func getTileData() -> Tile_Info:
	return $Body.Tile_Data

func post_Spread():
	selected = false
	$Body.changeHighLight(Color(0, 0, 0, 1))
	
	distance = 0
	$Body._on_control_mouse_exited()

func _on_control_mouse_entered() -> bool:
	if(LC_timer < 0.2):
		mouse_entered = true
		return true
	
	return false


func _on_control_mouse_exited() -> bool:
	mouse_entered = false
	if(!selected):
		return true
	
	return false
