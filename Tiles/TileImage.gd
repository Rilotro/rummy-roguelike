extends Control

class_name TileImage

var TileBodySprite: Sprite2D
var TileNumber: RichTextLabel
var EffectsRow: HBoxContainer

var tile: Tile

func _init(tile_toCopy: Tile) -> void:
	var tileSize: Vector2 = ResourceContainer.BASE_RESOURCE_SIZE
	
	if(tile_toCopy == null):
		tile_toCopy = Tile.getRandomTile()
	
	tile = tile_toCopy
	
	custom_minimum_size = tileSize
	
	TileBodySprite = Sprite2D.new()
	TileBodySprite.position = tileSize/2
	TileBodySprite.name = "TileBodySprite"
	add_child(TileBodySprite)
	
	if(tile_toCopy.jokerID < 0):
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
				newContainer = Tile.getEffectContainer(effect, tile_toCopy.color)
				#effectContainers.append(newContainer)
				EffectsRow.add_child(newContainer)
	else:
		TileBodySprite.scale = Vector2(0.5, 0.5)
		TileBodySprite.texture = tile_toCopy.getJokerImage()

func _ready() -> void:
	if(TileNumber != null):
		TileNumber.position = Vector2(0, 0)

func getPointsBubble(points: int = -1) -> SparkleContainer:
	if(points == -1):
		points = tile.points
	
	var SparkleContainerSize: Vector2 = Vector2(10+points, 10+points) * 2*scale
	var spreadSparkles: SparkleContainer = SparkleContainer.new(SparkleContainerSize, Vector2(points, 2*points), null, true)
	spreadSparkles.position = size/2
	add_child(spreadSparkles)
	
	var pointsLabel: Label = Label.new()
	pointsLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var textFontSize: int = 1
	var textSize: Vector2 = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize)
	while(textSize.x <= SparkleContainerSize.x && textSize.y <= SparkleContainerSize.y):
		textFontSize += 1
		textSize = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize) * pointBubbleScaleFactor*scale
	
	textFontSize -= 1
	textSize = pointsLabel.get_theme_font("font").get_string_size("+"+str(points), pointsLabel.horizontal_alignment, -1, textFontSize) * pointBubbleScaleFactor*scale
	
	pointsLabel.add_theme_font_size_override("font_size", textFontSize)
	pointsLabel.self_modulate = Color.BLACK
	pointsLabel.text = "+"+str(points)
	pointsLabel.position = -textSize/2
	pointsLabel.z_index = 3
	#pointsLabel.top_level = true
	
	spreadSparkles.add_child(pointsLabel)
	
	return spreadSparkles

static var pointSumBubble: SparkleContainer = null
static var pointSumLabel: Label = null
static var pointSumTween: Tween
static var currPointVal: int
static var currPointSum: int
static var pointBubbleScaleFactor: float = 1
static var activateFinished: int = 0

func activate(BigBubblePos_X: float) -> void:
	var pointsBubble: SparkleContainer = getPointsBubble(tile.points)
	
	pointsBubble.z_index = 2
	pointsBubble.position = size/2
	
	var radius: Vector2 = (TileContainer.BASE_RESOURCE_SIZE + pointsBubble.size)/2 + Vector2(10, 10)
	#var radius: Vector2 = Vector2(randf_range(100, 130))
	var angle: float = randf_range(0, PI)
	var displacement: Vector2 = Vector2(radius.x*cos(angle), radius.y*sin(angle))
	
	var sparkleTween: Tween = create_tween()
	#sparkleTween.tween_method(func(newVal: Vector2) -> void:
		#pointsBubble.position = newVal
		#pointsLabel.position = pointsBubble.global_position - pointsLabel.size/2, size/2, displacement, 0.3)
	
	sparkleTween.tween_property(pointsBubble, "position", size/2 + displacement, 0.3)
	
	await sparkleTween.finished
	
	if(pointSumBubble == null):
		currPointSum = 0
		currPointVal = 0
		pointSumBubble = getPointsBubble(0)
		pointSumLabel = pointSumBubble.get_child(0)
		pointSumBubble.reparent(get_parent())
		pointSumBubble.position = Vector2(BigBubblePos_X, 100)
	
	sparkleTween = create_tween()
	sparkleTween.tween_property(pointsBubble, "global_position", pointSumBubble.global_position, 0.3).set_trans(Tween.TRANS_BACK)
	sparkleTween.finished.connect(func() -> void:
		if(pointSumTween != null && pointSumTween.is_running()):
			pointSumTween.finished.emit()
			pointSumTween.kill()
			pointSumTween = null
		
		pointsBubble.queue_free()
		
		currPointSum += tile.points
		pointSumTween = create_tween()
		pointSumTween.tween_method(func(newVal: int) -> void:
			currPointVal = newVal
			pointSumBubble.size = Vector2(10+newVal, 10+newVal) * 2*scale
			pointSumBubble.LowerBound_density = newVal
			pointSumBubble.UpperBound_density = 2*newVal
			var textFontSize: int = 1
			var textSize: Vector2 = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize)
			while(textSize.x <= pointSumBubble.size.x && textSize.y <= pointSumBubble.size.y):
				textFontSize += 1
				textSize = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize) * pointBubbleScaleFactor*scale
			
			textFontSize -= 1
			textSize = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize) * pointBubbleScaleFactor*scale
			
			pointSumLabel.add_theme_font_size_override("font_size", textFontSize)
			pointSumLabel.text = "+"+str(newVal)
			pointSumLabel.position = -textSize/2, currPointVal, currPointSum, 0.7)
		
		pointSumTween.finished.connect(func() -> void: activateFinished += 1)
		)
