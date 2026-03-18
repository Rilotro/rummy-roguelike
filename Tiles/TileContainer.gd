extends ResourceContainer

class_name TileContainer

const TILE_BASE_SIZE: Vector2 = Vector2(75, 105)
const HIGHLIGHT_EXPANDED_SIZE: Vector2 = Vector2(85, 115)

var HighLight: Sprite2D
var TileBodySprite: Sprite2D
var TileNumber: RichTextLabel
var MouseInput: Control
var JokerFace: Sprite2D
var EffectsRow: HBoxContainer

var effectContainers: Array[Control]

var playerSpace: PlayerSpace

enum PlayerSpace{
	BOARD, RIVER, SPREAD, NOT_PLAYER
}

func _init(newResource: Tile_Info, newConType: ContainerType, effectsChance: int = -1, newPlayerSpace: PlayerSpace = PlayerSpace.NOT_PLAYER) -> void:
	resource_type = ResourceType.TILE
	container_type = newConType
	
	if(newResource == null):
		resource = Tile_Info.getRandomTile(effectsChance)
	else:
		resource = newResource
	
	assert(newConType != ContainerType.GAMEBAR, "Tiles cannot appear on the GameBar!")
	assert(newConType != ContainerType.PLAYER_TILE || newPlayerSpace != PlayerSpace.NOT_PLAYER, "If it's part of the Player Area, it must be specified what part of it!")
	
	HighLight = Sprite2D.new()
	HighLight.texture = CanvasTexture.new()
	HighLight.region_enabled = true
	HighLight.region_rect = Rect2(0, 0, 85, 115)
	HighLight.position = Vector2(37.5, 52.5)
	HighLight.visible = false
	HighLight.self_modulate = Color.GREEN
	HighLight.name = "HighLight"
	add_child(HighLight)
	
	TileBodySprite = Sprite2D.new()
	TileBodySprite.texture = CanvasTexture.new()
	TileBodySprite.region_enabled = true
	TileBodySprite.region_rect = Rect2(0, 0, 75, 105)
	TileBodySprite.position = Vector2(37.5, 52.5)
	TileBodySprite.name = "TileBodySprite"
	add_child(TileBodySprite)
	
	TileNumber = RichTextLabel.new()
	add_child(TileNumber)
	TileNumber.bbcode_enabled = true
	TileNumber.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	TileNumber.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	TileNumber.custom_minimum_size = Vector2(75, 52.5)
	TileNumber.set_anchors_preset(Control.PRESET_CENTER)
	TileNumber.size = Vector2(75, 52.5)
	#TileNumber.position = Vector2(-37.5, -52.5)
	TileNumber.mouse_filter = Control.MOUSE_FILTER_PASS
	TileNumber.add_theme_font_size_override("normal_font_size", 36)
	TileNumber.self_modulate = Color.BLACK
	TileNumber.material = ShaderMaterial.new()
	TileNumber.material.shader = load("res://RainbowNumber.gdshader")
	TileNumber.name = "TileNumber"
	
	JokerFace = Sprite2D.new()
	JokerFace.scale = Vector2(3, 3)
	TileBodySprite.position = Vector2(37.5, 52.5)
	JokerFace.name = "JokerFace"
	add_child(JokerFace)
	
	EffectsRow = HBoxContainer.new()
	EffectsRow.alignment = BoxContainer.ALIGNMENT_CENTER
	EffectsRow.custom_minimum_size = Vector2(75, 32)
	#EffectsRow.size = Vector2(25, 12)
	EffectsRow.position = Vector2(0, 62.75)#-37.5
	EffectsRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EffectsRow.add_theme_constant_override("separation", 4)
	EffectsRow.name = "EffectsRow"
	add_child(EffectsRow)
	
	if(resource.joker_id < 0):
		JokerFace.visible = false
		
		match resource.rarity:
			Tile_Info.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile_Info.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile_Info.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
		
		TileNumber.text = str(resource.number)
		if(resource.effects.has(Tile_Info.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = resource.color
		
		var newContainer: Control
		for effect in resource.effects:
			#if(effect != Tile_Info.Effect.RAINBOW):
			newContainer = resource.getEffectContainer(effect)
			effectContainers.append(newContainer)
			EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.visible = false
		TileNumber.visible = false
		EffectsRow.visible = false
		
		JokerFace.texture = resource.joker_image
	
	super()

func _ready() -> void:
	TileNumber.position = Vector2(0, 0)
	#EffectsRow.position = Vector2(-37.5, 10.25)

func REgenerateResource(newResource: Resource = null, effectsChance: int = -1) -> void:
	var newTile: Tile_Info
	
	if(newResource == null):
		newTile = Tile_Info.getRandomTile(effectsChance)
	else:
		newTile = newResource
	
	resource = newTile
	
	effectContainers.clear()
	for n in EffectsRow.get_children():
		n.remove_child(n)
		n.queue_free() 
	
	if(newTile.joker_id < 0):
		TileBodySprite.visible = true
		TileNumber.visible = true
		EffectsRow.visible = true
		
		match resource.rarity:
			Tile_Info.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile_Info.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile_Info.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
		
		TileNumber.text = str(resource.number)
		if(resource.effects.has(Tile_Info.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = resource.color
		
		var newContainer: Control
		for effect in resource.effects:
			#if(effect != Tile_Info.Effect.RAINBOW):
			newContainer = resource.getEffectContainer(effect)
			effectContainers.append(newContainer)
			EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.visible = false
		TileNumber.visible = false
		EffectsRow.visible = false

func REparent(newPlayerSpace: PlayerSpace) -> void:
	assert(container_type == ContainerType.PLAYER_TILE && newPlayerSpace != PlayerSpace.NOT_PLAYER, "Cannot move a Tile inside the Player Area outside of it!")
	
	playerSpace = newPlayerSpace

var isBeingMoved: bool
const MOVE_TILE_DURATION: float = 0.35

func moveTile(endPos: Vector2, tween: Tween = null, transOption: Tween.TransitionType = Tween.TRANS_BACK, easeOption: Tween.EaseType = Tween.EASE_IN) -> void:
	isBeingMoved = true
	z_index = 1
	
	if(tween == null):
		tween = GameScene.Game.get_tree().create_tween()

	tween.tween_property(self, "position", endPos, MOVE_TILE_DURATION).set_trans(transOption).set_ease(easeOption)
	
	await tween.finished
	z_index = 0
	isBeingMoved = false

func lateFinalPress() -> void:
	super()
	
	isMoving = false

var isMoving: bool = false

func pressing(delta: float) -> void:
	super(delta)
	
	if(pressingTimer > PRESS_TIMER_THRESHOLD):
		global_position = get_global_mouse_position() - TILE_BASE_SIZE/2
		isMoving = true

func _mouse_entered() -> void:#----------------------------------------------------------------------------------
	super()
	
	HighLight.visible = true

func _mouse_exited() -> void:
	super()
	
	if(isMoving):
		mouse_inside = true
		stillPressingInside = true
		return
	
	if(container_type == ContainerType.SELECTION && SelectScreen.finalSelections.has(resource)):
		return
	
	if(container_type == ContainerType.PLAYER_TILE && Player.selectedTiles.has(self)):
		return
	
	HighLight.visible = false
