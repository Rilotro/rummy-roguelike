extends Node2D

var Tile_Data: Tile_Info = null
var font_size: float = 16.0
var mouse_inside: bool = false
var tip_timer: float = 0
var tip_openned: bool =  false
var tip_UI: Control

var Spread_highligh: bool = false
var is_highlithing: bool = false

var tween

func _ready() -> void:
	#$TileNumber.scale = Vector2(1/scale.x, 1/scale.y)
	font_size *= scale.x

func _process(delta: float) -> void:
	if(Spread_highligh):
		if(!is_highlithing):
			is_highlithing = true
			tween = get_tree().create_tween()
			tween.tween_property($HighLight, "modulate:a", 1-$HighLight.modulate.a, 0.5)
			await tween.finished
			is_highlithing = false
	if(mouse_inside && !Tile.is_moving):
		tip_timer += delta
		if(tip_timer >= 1.0 && !tip_openned):
			tip_openned = true
			tip_UI = preload("res://UI_Tip.tscn").instantiate()
			tip_UI.initialise_tip(self)
			get_tree().root.get_child(0).add_child(tip_UI)
			tip_UI.z_index = 3
			#tip_UI.global_position = global_position + $TileBody.scale*scale/2 - Vector2(0, tip_UI.size.y/2)

func acc_size() -> Vector2:
	return $TileBody.scale*scale

func possible_Spread_highlight(activate: bool) -> void:
	if(activate):
		$HighLight.visible = true
		$HighLight.modulate = Color(0.9, 0.9, 0.3, 0)
		Spread_highligh = true
	else:
		if(tween != null):
			tween.kill()
			is_highlithing = false
		if(!mouse_inside):
			$HighLight.visible = false
		$HighLight.modulate = Color(0, 0, 0, 1)
		Spread_highligh = false

func change_info(new_info: Tile_Info) -> void:
	Tile_Data = new_info
	
	if(Tile_Data.joker_id < 0):
		$TileNumber.text = str(Tile_Data.number)
		if(Tile_Data.effects["rainbow"]):
			$TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			$TileNumber.set_instance_shader_parameter("is_rainbow", false)
			match Tile_Data.color:
				1:
					$TileNumber.modulate = Color(0, 0, 0, 1)
					$Duplicate_Icon.modulate = Color(0, 0, 0, 1)
				2:
					$TileNumber.modulate = Color(0, 0, 1, 1)
					$Duplicate_Icon.modulate = Color(0, 0, 1, 1)
				3:
					$TileNumber.modulate = Color(0, 1, 0, 1)
					$Duplicate_Icon.modulate = Color(0, 1, 0, 1)
				4:
					$TileNumber.modulate = Color(1, 0, 0, 1)
					$Duplicate_Icon.modulate = Color(1, 0, 0, 1)
		
		if(Tile_Data.effects["duplicate"]):
			$Duplicate_Icon.visible = true
		else:
			$Duplicate_Icon.visible = false
		
		match new_info.rarity:
			"gold":
				$TileBody.self_modulate = Color(1,0.843,0, 1)
			"silver":
				$TileBody.self_modulate = Color(0.75,0.75,0.75, 1)
			"bronze":
				$TileBody.self_modulate = Color(0.804, 0.498, 0.196, 1)
			"porcelain":
				$TileBody.self_modulate = Color(1, 1, 1, 1)
	else:
		match Tile_Data.joker_id:
			0:
				$Joker_Face.texture = load("res://jokers/Untitled.png")
				$TileNumber.text = ""
				$Joker_Face.visible = true
			1:
				$TileNumber.text = ""
				$Joker_Face.texture = load("res://jokers/Partygoer.png")
				$Joker_Face.visible = true
			2:
				$TileNumber.text = ""
				$Joker_Face.texture = load("res://jokers/Banker.png")
				$Joker_Face.visible = true

func changeHighLight(new_color: Color) -> void:
	$HighLight.modulate = new_color

func _on_control_mouse_entered() -> void:
	mouse_inside = true
	var eligible: bool = get_parent()._on_control_mouse_entered()
	if(!Spread_highligh && eligible):
		$HighLight.visible = true


func _on_control_mouse_exited() -> void:
	mouse_inside = false
	tip_timer = 0
	if(tip_openned):
		tip_openned = false
		tip_UI.queue_free()
	var eligible: bool = get_parent()._on_control_mouse_exited()
	if(!Spread_highligh && eligible):
		$HighLight.visible = false
	
