extends ResourceContainer

class_name TileContainer

#const TILE_BASE_SIZE: Vector2 = Vector2(75, 105)
const HIGHLIGHT_EXPANDED_SIZE: Vector2 = BASE_RESOURCE_SIZE + Vector2(10, 10)
const HIGHLIGHT_BASE_COLOR: Color = Color.GREEN
const HIGHLIGHT_DISCARD_COLOR: Color = Color.RED
const HIGHLIGHT_RIVER_COLOR: Color = Color.BLUE

var Highlight: Sprite2D
var TileBodySprite: Sprite2D
var TileNumber: RichTextLabel
var MouseInput: Control
var JokerFace: Sprite2D
var SpreadSelectionCount: Label
var EffectsRow: HBoxContainer

var effectContainers: Array[Control]
var playerSpace: PlayerSpace
var periodicHighlighting: bool = false
var HighlightTween: Tween

enum PlayerSpace{
	BOARD, RIVER, SPREAD, NOT_PLAYER
}

func _init(newResource: Tile, newConType: ContainerType, effectsChance: int = -1, newPlayerSpace: PlayerSpace = PlayerSpace.NOT_PLAYER) -> void:
	resource_type = ResourceType.TILE
	container_type = newConType
	
	if(newResource == null):
		resource = Tile.getRandomTile(effectsChance)
	else:
		resource = newResource
	
	assert(newConType != ContainerType.GAMEBAR, "Tiles cannot appear on the GameBar!")
	assert(newConType != ContainerType.PLAYER_TILE || newPlayerSpace != PlayerSpace.NOT_PLAYER, "If it's part of the Player Area, it must be specified what part of it!")
	
	Highlight = Sprite2D.new()
	Highlight.texture = CanvasTexture.new()
	Highlight.region_enabled = true
	Highlight.region_rect = Rect2(0, 0, 85, 115)
	Highlight.position = Vector2(37.5, 52.5)
	Highlight.visible = false
	Highlight.self_modulate = HIGHLIGHT_BASE_COLOR
	Highlight.name = "Highlight"
	add_child(Highlight)
	
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
	TileNumber.mouse_filter = Control.MOUSE_FILTER_IGNORE
	TileNumber.add_theme_font_size_override("normal_font_size", 36)
	TileNumber.self_modulate = Color.BLACK
	TileNumber.material = ShaderMaterial.new()
	TileNumber.material.shader = load("res://RainbowNumber.gdshader")
	TileNumber.name = "TileNumber"
	
	JokerFace = Sprite2D.new()
	JokerFace.scale = Vector2(0.5, 0.5)
	JokerFace.position = Vector2(37.5, 52.5)
	JokerFace.name = "JokerFace"
	add_child(JokerFace)
	
	SpreadSelectionCount = Label.new()
	SpreadSelectionCount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SpreadSelectionCount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	SpreadSelectionCount.self_modulate = Color.GOLD
	SpreadSelectionCount.visible = false
	var textSize_Y: float = SpreadSelectionCount.get_theme_font("font").get_string_size("0").y
	SpreadSelectionCount.position.y = -textSize_Y-5
	SpreadSelectionCount.z_index = 1
	add_child(SpreadSelectionCount)
	
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
			Tile.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
		
		TileNumber.text = str(resource.number)
		if(resource.effects.has(Tile.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = resource.color
		
		var newContainer: Control
		for effect in resource.effects:
			if(effect != Tile.Effect.RAINBOW):
				newContainer = resource.getEffectContainer(effect)
				effectContainers.append(newContainer)
				EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.visible = false
		TileNumber.visible = false
		EffectsRow.visible = false
		
		JokerFace.texture = resource.getJokerImage()
	
	super()

func _ready() -> void:
	super()
	TileNumber.position = Vector2(0, 0)
	#EffectsRow.position = Vector2(-37.5, 10.25)

func _process(delta: float) -> void:
	super(delta)
	
	HandlePeriodicHighlight()
	handleQueuedSpread()

func getName(Tip: UITip) -> String:
	return resource.getName()

func getDescription(Tip: UITip) -> String:
	return resource.getDescription()

func getKeywords(Tip: UITip) -> String:
	return resource.getKeywords()

func REgenerateResource(newResource: Resource = null, effectsChance: int = -1) -> void:
	var newTile: Tile
	
	if(newResource == null):
		newTile = Tile.getRandomTile(effectsChance)
	else:
		newTile = newResource
	
	resource = newTile
	
	effectContainers.clear()
	for n in EffectsRow.get_children():
		n.remove_child(n)
		n.queue_free() 
	
	if(newTile.joker_id < 0):
		JokerFace.visible = false
		
		TileBodySprite.visible = true
		TileNumber.visible = true
		EffectsRow.visible = true
		
		match resource.rarity:
			Tile.Rarity.BRONZE:
				TileBodySprite.self_modulate = Color(0.804, 0.498, 0.196, 1)
			Tile.Rarity.SILVER:
				TileBodySprite.self_modulate = Color.SILVER
			Tile.Rarity.GOLD:
				TileBodySprite.self_modulate = Color.GOLD
		
		TileNumber.text = str(resource.number)
		if(resource.effects.has(Tile.Effect.RAINBOW)):
			TileNumber.set_instance_shader_parameter("is_rainbow", true)
		else:
			TileNumber.set_instance_shader_parameter("is_rainbow", false)
			TileNumber.self_modulate = resource.color
		
		var newContainer: Control
		for effect in resource.effects:
			#if(effect != Tile.Effect.RAINBOW):
			newContainer = resource.getEffectContainer(effect)
			effectContainers.append(newContainer)
			EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.visible = false
		TileNumber.visible = false
		EffectsRow.visible = false
		
		JokerFace.visible = true
		JokerFace.texture = resource.getJokerImage()
	
	if(container_type == ContainerType.SHOP):
		price = 0#resource.getShopPrice()
		checkShopAffordability()

func checkShopAffordability() -> void:
	super()
	
	if(CostText.self_modulate == Color.WHITE):
		Highlight.self_modulate = HIGHLIGHT_BASE_COLOR
	else:
		Highlight.self_modulate = CostText.self_modulate

func REparent(newPlayerSpace: PlayerSpace) -> void:
	assert(container_type == ContainerType.PLAYER_TILE && newPlayerSpace != PlayerSpace.NOT_PLAYER, "Cannot move a Tile inside the Player Area outside of it!")
	
	playerSpace = newPlayerSpace

var isBeingMoved: bool
const MOVE_TILE_DURATION: float = 0.35

func moveTile(endPos: Vector2, tween: Tween = null, transOption: Tween.TransitionType = Tween.TRANS_BACK, easeOption: Tween.EaseType = Tween.EASE_IN, duration: float = MOVE_TILE_DURATION) -> void:
	isBeingMoved = true
	z_index = 1
	
	if(tween == null):
		tween = GameScene.Game.get_tree().create_tween()

	tween.tween_property(self, "position", endPos, duration).set_trans(transOption).set_ease(easeOption)
	
	await tween.finished
	z_index = 0
	isBeingMoved = false

func onSpreadQueueEffects() -> float:
	spreadQueued = true
	var onSpreadEffectsDuration: float = 0.3 + resource.getOnSpreadEffectsDuration(self)
	
	#for effect in resource.effects:
		#match effect:
			#Tile.Effect.DUPLICATE:
				#onSpreadEffectsDuration += DUPLICATE_EFFECT_DURATION
	
	return onSpreadEffectsDuration

var isActingOnSpreadEffects: bool = false
const DUPLICATE_EFFECT_DURATION: float = 0.25
var spreadQueued: bool = false

func handleQueuedSpread() -> void:
	if(!spreadQueued):
		return
	
	if(isBeingMoved):
		return
	
	spreadQueued = false
	isActingOnSpreadEffects = true
	
	#pointsGlitter(GameScene.MainPlayer.ExpBar.global_position)
	
	resource.onSpreadEffects(self)
	
	isActingOnSpreadEffects = false

func pointsGlitter(target_globalPos: Vector2, points: int = -1) -> void:
	if(points == -1):
		points = resource.points
	
	var sparkleTween: Tween = create_tween()
	var SparkleContainerSize: Vector2 = Vector2(10+points, 10+points)
	var spreadSparkles: SparkleContainer = SparkleContainer.new(SparkleContainerSize, Vector2(points, 2*points), SparkleContainer.HoleShape.NULL, Vector2(-1, -1), true)
	spreadSparkles.position = size/2
	add_child(spreadSparkles)
	
	var pointsLabel: Label = Label.new()
	pointsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var textFontSize: int = 1
	var textSize: Vector2 = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize)
	while(textSize.x <= SparkleContainerSize.x && textSize.y <= SparkleContainerSize.y):
		textFontSize += 1
		textSize = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize)
	
	textFontSize -= 1
	textSize = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize)
	
	pointsLabel.add_theme_font_size_override("font_size", textFontSize)
	pointsLabel.self_modulate = Color.BLACK
	pointsLabel.text = "+"+str(points)
	pointsLabel.position = global_position + size/2 - textSize/2
	pointsLabel.z_index = 1
	pointsLabel.top_level = true
	
	spreadSparkles.add_child(pointsLabel)
	
	var radius: float = randf_range(100, 130)
	var angle: float = randf_range(-2*PI/3, -2*PI/6)
	var displacement: Vector2 = Vector2(radius*cos(angle), radius*sin(angle))#spreadSparkles.position + 
	
	#sparkleTween.tween_property(spreadSparkles, "position", displacement, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)#0.2
	sparkleTween.tween_method(func(newVal: Vector2) -> void:
		spreadSparkles.global_position = newVal
		pointsLabel.global_position = newVal - textSize/2
		, spreadSparkles.global_position, spreadSparkles.global_position+displacement, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#await get_tree().create_timer(2).timeout
	
	#sparkleTween.tween_property(spreadSparkles, "global_position", target_globalPos, DUPLICATE_EFFECT_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	sparkleTween.tween_method(func(newVal: Vector2) -> void:
		spreadSparkles.global_position = newVal
		pointsLabel.global_position = newVal - textSize/2
		, spreadSparkles.global_position+displacement, target_globalPos, DUPLICATE_EFFECT_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	await sparkleTween.finished
	spreadSparkles.queue_free()
	GameScene.GameShop.update_currency(points)
	GameScene.MainPlayer.ExpBar.gainExperience(points)

func EN_DISablePeriodicHighlight(enable: bool = true, keepHighlight: bool = false) -> void:
	periodicHighlighting = enable
	if(enable):
		Highlight.visible = true
		Highlight.self_modulate.a = 0
	else:
		if(HighlightTween != null && HighlightTween.is_running()):
			HighlightTween.stop()
		
		Highlight.visible = keepHighlight
		Highlight.self_modulate.a = 1

func HandlePeriodicHighlight() -> void:
	if(periodicHighlighting):
		if(HighlightTween == null || !HighlightTween.is_running()):
			HighlightTween = create_tween()
			HighlightTween.tween_property(Highlight, "self_modulate:a", 1-Highlight.self_modulate.a, 0.75)

func finalPress() -> void:
	SpreadSelectionCount.visible = false
	
	if(container_type == ContainerType.PLAYER_TILE):
		match playerSpace:
			PlayerSpace.RIVER:
				if(!BeaverTeeth.Beaver_Teeth_Activated):
					return
				#if(Player.isDiscarding):
					#return
				#
				#var riverIndex: int = River.river.find(self)
				#if(River.river.size()-riverIndex-1 > River.bait):
					#return
			PlayerSpace.SPREAD:
				return
			
	
	super()
	
	#if(playerSpace == PlayerSpace.BOARD && !Player.isDiscarding && Player.selectedTiles.has(self)):

func showSpreadSelectionCount(slectionIndex: int) -> void:
	SpreadSelectionCount.text = str(slectionIndex)
	var textSize_X: float = SpreadSelectionCount.get_theme_font("font").get_string_size(str(slectionIndex)).x
	SpreadSelectionCount.position.x = getSize().x/2 - textSize_X/2
	
	SpreadSelectionCount.visible = true

func lateFinalPress() -> void:
	super()
	
	if(isMoving):
		isMoving = false
		z_index = 0
		GameScene.MainPlayer.GameBoard.endMovement(self)

var isMoving: bool = false

func pressing(delta: float) -> void:
	super(delta)
	
	if(pressingTimer > PRESS_TIMER_THRESHOLD && playerSpace == PlayerSpace.BOARD):
		global_position = get_global_mouse_position() - BASE_RESOURCE_SIZE/2
		isMoving = true
		z_index = 1
		GameScene.MainPlayer.GameBoard.HighlightMovingTileFinalPos(self)

func _mouse_entered() -> void:#----------------------------------------------------------------------------------
	super()
	
	if(container_type == ContainerType.PLAYER_TILE && playerSpace == PlayerSpace.SPREAD):
		return
	
	if(container_type == ContainerType.PLAYER_TILE && playerSpace == PlayerSpace.RIVER):
		var riverIndex: int = River.river.find(self)
		if(River.river.size()-riverIndex-1 > River.bait):
			Highlight.self_modulate = HIGHLIGHT_DISCARD_COLOR
		else:
			Highlight.self_modulate = HIGHLIGHT_RIVER_COLOR
	
	Highlight.visible = true

func _mouse_exited() -> void:
	super()
	
	if(isMoving):
		mouse_inside = true
		stillPressingInside = true
		return
	
	if(container_type == ContainerType.SELECTION && SelectScreen.finalSelections.has(self)):
		return
	
	if(container_type == ContainerType.PLAYER_TILE && Player.selectedTiles.has(self)):
		return
	
	if(periodicHighlighting):
		return
	
	Highlight.visible = false
