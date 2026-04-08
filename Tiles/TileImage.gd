extends Control

class_name TileImage

var TileBodySprite: Sprite2D
var TileNumber: RichTextLabel
var EffectsRow: HBoxContainer

func _init(tile_toCopy: Tile) -> void:
	var tileSize: Vector2 = ResourceContainer.BASE_RESOURCE_SIZE
	
	custom_minimum_size = tileSize
	
	TileBodySprite = Sprite2D.new()
	TileBodySprite.position = tileSize/2
	TileBodySprite.name = "TileBodySprite"
	add_child(TileBodySprite)
	
	if(tile_toCopy.joker_id < 0):
		TileBodySprite.texture = CanvasTexture.new()
		TileBodySprite.region_enabled = true
		TileBodySprite.region_rect = Rect2(Vector2(0, 0), tileSize)
		
		TileNumber = RichTextLabel.new()
		add_child(TileNumber)
		TileNumber.bbcode_enabled = true
		TileNumber.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		TileNumber.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		TileNumber.custom_minimum_size = Vector2(tileSize.x, tileSize.y/2)
		TileNumber.set_anchors_preset(Control.PRESET_CENTER)
		#TileNumber.size = Vector2(75, 52.5)
		#TileNumber.position = Vector2(-37.5, -52.5)
		TileNumber.mouse_filter = Control.MOUSE_FILTER_PASS
		TileNumber.add_theme_font_size_override("normal_font_size", 36)
		TileNumber.self_modulate = Color.BLACK
		TileNumber.material = ShaderMaterial.new()
		TileNumber.material.shader = load("res://RainbowNumber.gdshader")
		TileNumber.name = "TileNumber"
		
		EffectsRow = HBoxContainer.new()
		EffectsRow.alignment = BoxContainer.ALIGNMENT_CENTER
		EffectsRow.custom_minimum_size = Vector2(tileSize.x, 32)
		#EffectsRow.size = Vector2(25, 12)
		EffectsRow.position = Vector2(0, 62.75)#-37.5
		EffectsRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		EffectsRow.add_theme_constant_override("separation", 4)
		EffectsRow.name = "EffectsRow"
		add_child(EffectsRow)
		
		match tile_toCopy.rarity:
			Tile.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
		
		TileNumber.text = str(tile_toCopy.number)
		if(tile_toCopy.effects.has(Tile.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = tile_toCopy.color
		
		var newContainer: Control
		for effect in tile_toCopy.effects:
			if(effect != Tile.Effect.RAINBOW):
				newContainer = tile_toCopy.getEffectContainer(effect)
				#effectContainers.append(newContainer)
				EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.scale = Vector2(0.5, 0.5)
		TileBodySprite.texture = tile_toCopy.getJokerImage()

func _ready() -> void:
	if(TileNumber != null):
		TileNumber.position = Vector2(0, 0)
