extends Node2D

class_name Tile

var mouse_entered: bool = false
var selected: bool = false
var is_moving: bool  = false
#var mouse_distance: Vector2
var distance: float = 0
var LC_timer: float = 0.0
var orig_pos: Vector2

#var info_changed: bool = false

#var number: int
#var color: int

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
				get_parent().update_selected_tiles(self, selected)
				if(selected):
					$Body.changeHighLight(select_Color)
				else:
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
		orig_pos = global_position
	
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

func tile_move():
	var target_pos: Vector2 = (get_global_mouse_position() - Vector2(5, 28)).snapped(Vector2(30, 40)) + Vector2(5, 28)
	if(target_pos != global_position):
		target_pos = get_parent().get_height_limit(target_pos, global_position, self)

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
	
	return final_points

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
