extends Node2D

class_name TileBody

var Tile_Data: Tile_Info = null
var font_size: float = 16.0
var mouse_inside: bool = false
var tip_timer: float = 0
var tip_openned: bool =  false
var tip_UI: Control

var Spread_highligh: bool = false
var is_highlithing: bool = false

var tween

@export var HighLight: Sprite2D
@export var TileBodySprite: Sprite2D
@export var TileNumber: RichTextLabel
@export var MouseInput: Control
@export var JokerFace: Sprite2D
@export var EffectsRow: HBoxContainer
var effectContainers: Array[Control]

func _init(tile_info: Tile_Info) -> void:
	Tile_Data = tile_info
	
	HighLight = Sprite2D.new()
	HighLight.texture = CanvasTexture.new()
	HighLight.region_enabled = true
	HighLight.region_rect = Rect2(0, 0, 30, 40)
	HighLight.visible = false
	HighLight.self_modulate = Color.BLACK
	HighLight.name = "HighLight"
	add_child(HighLight)
	
	TileBodySprite = Sprite2D.new()
	TileBodySprite.texture = CanvasTexture.new()
	TileBodySprite.region_enabled = true
	TileBodySprite.region_rect = Rect2(0, 0, 25, 35)
	
	if(tile_info.joker_id < 0):
		match tile_info.rarity:
			Tile_Info.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile_Info.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile_Info.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
	else:
		TileBodySprite.visible = false
	
	TileBodySprite.name = "TileBodySprite"
	add_child(TileBodySprite)
	
	TileNumber = RichTextLabel.new()
	TileNumber.bbcode_enabled = true
	TileNumber.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TileNumber.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	TileNumber.custom_minimum_size = Vector2(25, 23)
	TileNumber.set_anchors_preset(Control.PRESET_CENTER)
	TileNumber.size = Vector2(25, 23)
	TileNumber.position = Vector2(-12.5, -17.5)
	TileNumber.mouse_filter = Control.MOUSE_FILTER_PASS
	TileNumber.add_theme_font_size_override("normal_font_size", 36)
	TileNumber.self_modulate = Color.BLACK
	TileNumber.material = ShaderMaterial.new()
	TileNumber.material.shader = load("res://RainbowNumber.gdshader")
	
	if(tile_info.joker_id < 0):
		TileNumber.text = str(tile_info.number)
		if(tile_info.effects.has(Tile_Info.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = tile_info.color
	else:
		TileNumber.visible = false
	
	TileNumber.name = "TileNumber"
	add_child(TileNumber)
	
	MouseInput = Control.new()
	MouseInput.custom_minimum_size = Vector2(25, 35)
	MouseInput.set_anchors_preset(Control.PRESET_CENTER)
	MouseInput.size = Vector2(25, 35)
	MouseInput.position = Vector2(-12.5, -17.5)
	MouseInput.mouse_filter = Control.MOUSE_FILTER_PASS
	MouseInput.mouse_entered.connect(_on_control_mouse_entered)
	MouseInput.mouse_exited.connect(_on_control_mouse_exited)
	MouseInput.name = "MouseInput"
	add_child(MouseInput)
	
	JokerFace = Sprite2D.new()
	
	if(tile_info.joker_id < 0):
		JokerFace.visible = false
	else:
		JokerFace.texture = tile_info.joker_image
	
	JokerFace.name = "JokerFace"
	add_child(JokerFace)
	
	EffectsRow = HBoxContainer.new()
	EffectsRow.alignment = BoxContainer.ALIGNMENT_CENTER
	EffectsRow.custom_minimum_size = Vector2(25, 12)
	EffectsRow.size = Vector2(25, 12)
	EffectsRow.position = Vector2(-12.5, 5.5)
	EffectsRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EffectsRow.add_theme_constant_override("separation", 2)
	
	if(tile_info.joker_id < 0):
		var newContainer: Control
		for effect in tile_info.effects:
			#if(effect != Tile_Info.Effect.RAINBOW):
			newContainer = tile_info.getEffectContainer(effect)
			effectContainers.append(newContainer)
			EffectsRow.add_child(newContainer)
	else:
		EffectsRow.visible = false
	
	EffectsRow.name = "EffectsRow"
	add_child(EffectsRow)

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
			#tip_UI = UITip.new(UITip.UIType.TILE, self)#preload("res://UI_Tip.tscn").instantiate()
			#get_tree().root.get_child(0).add_child(tip_UI)
			#tip_UI.initialise_tip(self)
			#tip_UI.z_index = 3
			#tip_UI.global_position = global_position + $TileBody.scale*scale/2 - Vector2(0, tip_UI.size.y/2)

func acc_size() -> Vector2:
	return TileBodySprite.region_rect.size*TileBodySprite.scale*scale

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

func change_info(new_info: Tile_Info = Tile_Data) -> void:
	Tile_Data = new_info
	
	if(Tile_Data.joker_id < 0):
		$TileNumber.text = str(Tile_Data.number)
		if(Tile_Data.effects.find(Tile_Info.Effect.RAINBOW) >= 0):
			$TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			$TileNumber.set_instance_shader_parameter("is_rainbow", false)
			#match Tile_Data.color:
				#1:
					#$TileNumber.modulate = Color(0, 0, 0, 1)
					#$HBoxContainer/DuplicateIcon.modulate = Color(0, 0, 0, 1)
					#$HBoxContainer/WingedIcon.modulate = Color(0.021, 0.021, 0.021, 1)
				#2:
					#$TileNumber.modulate = Color(0, 0, 1, 1)
					#$HBoxContainer/DuplicateIcon.modulate = Color(0, 0, 1, 1)
					#$HBoxContainer/WingedIcon.modulate = Color(0, 0, 1, 1)
				#3:
					#$TileNumber.modulate = Color(0, 1, 0, 1)
					#$HBoxContainer/DuplicateIcon.modulate = Color(0, 1, 0, 1)
					#$HBoxContainer/WingedIcon.modulate = Color(0, 1, 0, 1)
				#4:
					#$TileNumber.modulate = Color(1, 0, 0, 1)
					#$HBoxContainer/DuplicateIcon.modulate = Color(1, 0, 0, 1)
					#$HBoxContainer/WingedIcon.modulate = Color(1, 0, 0, 1)
			
			$TileNumber.modulate = Tile_Data.color
			#$HBoxContainer/DuplicateIcon.modulate = Tile_Data.color
			#$HBoxContainer/WingedIcon.modulate = Tile_Data.color
			#if(Tile_Data.color == Color.BLACK):
				#$HBoxContainer/WingedIcon.modulate += Color(0.021, 0.021, 0.021, 0)
		
		#if(Tile_Data.effects.find(Tile_Info.Effect.DUPLICATE) >= 0):
			#$HBoxContainer/DuplicateIcon.visible = true
		#else:
			#$HBoxContainer/DuplicateIcon.visible = false
		#
		#if(Tile_Data.effects.find(Tile_Info.Effect.WINGED) >= 0):
			#$HBoxContainer/WingedIcon.visible = true
		#else:
			#$HBoxContainer/WingedIcon.visible = false
		
		match new_info.rarity:
			Tile_Info.Rarity.GOLD:
				TileBodySprite.self_modulate = Color(1,0.843,0, 1)
			Tile_Info.Rarity.SILVER:
				TileBodySprite.self_modulate = Color(0.75,0.75,0.75, 1)
			Tile_Info.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile_Info.Rarity.PORCELAIN:
				TileBodySprite.self_modulate = Color(1, 1, 1, 1)
	else:
		match Tile_Data.joker_id:
			0:
				$JokerFace.texture = load("res://jokers/Untitled.png")
				$TileNumber.text = ""
				$JokerFace.visible = true
			1:
				$TileNumber.text = ""
				$JokerFace.texture = load("res://jokers/Partygoer.png")
				$JokerFace.visible = true
			2:
				$TileNumber.text = ""
				$JokerFace.texture = load("res://jokers/Banker.png")
				$JokerFace.visible = true
			3:
				$TileNumber.text = ""
				$JokerFace.texture = load("res://jokers/Architect.png")
				$JokerFace.visible = true
			4:
				$TileNumber.text = ""
				$JokerFace.texture = load("res://jokers/Vampire.png")
				$JokerFace.visible = true

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
