extends Node2D

class_name Tile

var mouse_entered: bool = false
var selected: bool = false
static var is_moving: bool  = false
var LC_timer: float = 0.0

var mouse_still_inside: bool = false

var endPos_Highlight: PackedScene = preload("res://endPos_Highlight.tscn")
var curr_EPH: Sprite2D

static var select_Color: Color = Color(1, 1, 0, 1)

var Player: Node2D
var parentEffector: Node2D

func change_info(new_info: Tile_Info):
	$Body.change_info(new_info)

func REparent(new_Player: Node2D, new_parentEffector: Node2D) -> void:
	Player = new_Player
	parentEffector = new_parentEffector

func _process(delta: float) -> void:
	if(Input.is_action_just_released("Left_Click")):
		z_index = 0
		if(LC_timer >= 0.2):
			is_moving = false
			LC_timer = 0.0
			parentEffector.reposition_Tile(self)
		elif(mouse_still_inside):
			if(Player.my_turn && !Player.is_spreading && "Board_Tiles" in parentEffector):
				selected = !selected
				possible_Spread_highlight(false)
				Player.update_selected_tiles(self, selected)
				if(selected):
					$Body.changeHighLight(select_Color)
				elif(!$Body.Spread_highligh):
					$Body.changeHighLight(Color(0, 0, 0, 1))
			elif(Player.my_turn && !Player.is_spreading && "Discard_River" in parentEffector && !Player.discarding):
				selected = !selected
				Player.update_selected_tiles(self, selected)
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
				if(LC_timer < 0.2 && "Board_Tiles" in parentEffector && Player.my_turn):
					LC_timer += delta
					if(LC_timer >= 0.2):
						z_index = 1
						is_moving = true
						$Body._on_control_mouse_exited()
			else:
				mouse_still_inside = false
		if(LC_timer >= 0.2):
			mouse_still_inside = false
			tile_move()

func possible_Spread_highlight(activate: bool) -> void:
	$Body.possible_Spread_highlight(activate)

func tile_move():
	global_position = get_global_mouse_position()
	parentEffector.HighLightEndPos(self)

var PointText: RichTextLabel
var SR: Node2D

func on_spread(PT_finalpos: Vector2 = Vector2(0, 0)) -> int:
	var parentRot: float = Player.rotation
	if(PT_finalpos == Vector2(0, 0)):
		PT_finalpos = Vector2(50*sin(parentRot), -40*cos(parentRot))
	var TD: Tile_Info = $Body.Tile_Data
	var final_points: int = TD.points
	
	if(TD.joker_id < 0):
		if(TD.effects["duplicate"] && Player.is_MainInstance):
			var modified_effects: Dictionary = TD.effects
			modified_effects["duplicate"] = false
			Player.add_tile_to_deck(Tile_Info.new(TD.number, TD.color, TD.joker_id, TD.rarity, null, modified_effects))
	else:
		match TD.joker_id:
			1:
				final_points += 10*(Player.selected_tiles.size()-1)
			2:
				if(Player.is_MainInstance):
					Player.get_parent().Gain_Freebie(1)
	
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
	var B: Vector2 = $Body.acc_size()
	var XSizeDistance_B: Vector2 = Vector2(B.x*cos(parentRot), B.x*sin(parentRot))/2.0
	var YSizeDistance_B: Vector2 = Vector2(-B.y*sin(parentRot), B.y*cos(parentRot))/2.0
	PointText.global_position -= XSizeDistance_B + YSizeDistance_B
	move_child(PointText, 0)
	move_child(SR, 0)
	var tween = get_tree().create_tween()
	SR.change_road(global_position, Vector2(30, 42), 0.3, tween, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.parallel().tween_property(PointText, "global_position", PointText.global_position+PT_finalpos, 0.75).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	return final_points

func UI_add_score(BigScore: RichTextLabel, BigPoints: int, Spread_size: int) -> void:
	#530.0  628.0
	var tween = get_tree().create_tween()
	tween.set_parallel()
	SR.HB_density = 3
	SR.LB_density = -2
	
	var parentRot: float = Player.rotation
	
	var XSizeDistance_BS: Vector2 = Vector2(BigScore.custom_minimum_size.x*cos(parentRot), BigScore.custom_minimum_size.x*sin(parentRot))/2.0
	var YSizeDistance_BS: Vector2 = Vector2(-BigScore.custom_minimum_size.y*sin(parentRot), BigScore.custom_minimum_size.y*cos(parentRot))/2.0
	
	var XSizeDistance_PT: Vector2 = Vector2(PointText.custom_minimum_size.x*cos(parentRot), PointText.custom_minimum_size.x*sin(parentRot))/2.0
	var YSizeDistance_PT: Vector2 = Vector2(-PointText.custom_minimum_size.y*sin(parentRot), PointText.custom_minimum_size.y*cos(parentRot))/2.0
	
	SR.change_road(BigScore.global_position + XSizeDistance_BS + YSizeDistance_BS, PointText.get_theme_font("normal_font").get_string_size("+5000"), 1, tween, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.tween_property(PointText, "global_position", BigScore.global_position - XSizeDistance_PT - YSizeDistance_PT + XSizeDistance_BS + YSizeDistance_BS, 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	if(BigScore.text == ""):
		BigScore.fit_content = true
		BigScore.scroll_active = false
		BigScore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		BigScore.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		BigScore.modulate = Color(1, 1, 0, 1)
		BigScore.add_theme_font_size_override("normal_font_size", 16)
		BigScore.text = "+0"
		
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

func update_BigScore(BigPoints:int, BigScore: RichTextLabel):
	BigScore.text = "+" + str(BigPoints)

var is_being_moved: bool = false

func moveTile(endPos: Vector2, duration: float = 0.5, local: bool = false) -> void:
	is_being_moved = true
	z_index = 1
	var tween = get_tree().create_tween()
	if(local):
		tween.tween_property(self, "position", endPos, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(self, "global_position", endPos, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	z_index = 0
	is_being_moved = false

func is_on_Board() -> bool:
	if(parentEffector == null):
		return false
	return "Board_Tiles" in parentEffector

func is_in_River() -> bool:
	if(parentEffector == null):
		return false
	return "Discard_River" in parentEffector

func getTileData() -> Tile_Info:
	return $Body.Tile_Data

func post_Spread():
	selected = false
	$Body.changeHighLight(Color(0, 0, 0, 1))
	$Body._on_control_mouse_exited()
	$Body.possible_Spread_highlight(false)

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
