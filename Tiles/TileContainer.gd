@warning_ignore("missing_tool")
extends GoodButton

class_name TileContainer

const HIGHLIGHT_EXPANDED_SIZE: Vector2 = BASE_RESOURCE_SIZE + Vector2(10, 10)
const HIGHLIGHT_BASE_COLOR: Color = Color.GREEN
const HIGHLIGHT_DISCARD_COLOR: Color = Color.RED

var Highlight: Sprite2D
var FlashingHighlight: Sprite2D
var SpreadSelectionCount: Label
var EffectsRow: HBoxContainer
var flashTween: Tween = null

var tile: Tile

func _init(t: Tile) -> void:
	if(t == null):
		t = Tile.getRandomTile()
	
	tile = t
	
	Highlight = Sprite2D.new()
	Highlight.texture = CanvasTexture.new()
	Highlight.region_enabled = true
	Highlight.region_rect = Rect2(0, 0, 85, 115)
	Highlight.position = Vector2(37.5, 52.5)
	Highlight.visible = false
	Highlight.self_modulate = HIGHLIGHT_BASE_COLOR
	Highlight.name = "Highlight"
	add_child(Highlight)
	
	FlashingHighlight = Sprite2D.new()
	FlashingHighlight.texture = CanvasTexture.new()
	FlashingHighlight.region_enabled = true
	FlashingHighlight.region_rect = Rect2(0, 0, 85, 115)
	FlashingHighlight.position = Vector2(37.5, 52.5)
	FlashingHighlight.visible = false
	FlashingHighlight.self_modulate = HIGHLIGHT_BASE_COLOR
	FlashingHighlight.name = "FlashingHighlight"
	add_child(FlashingHighlight)
	
	var containerColor: Color = Tile.getRarityColor(tile.rarity)
	
	super(str(tile.number)+"\n", containerColor, BASE_RESOURCE_SIZE)#, tile.getJokerImage(), true, tile.getName ,tile.getKeywords ,tile.getDescription)
	ButtonText.add_theme_font_size_override("font_size", 36)
	text_color = tile.color
	HighlighColor = containerColor
	DisabledColor = containerColor
	PressedColor = containerColor
	
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
	EffectsRow.position = Vector2(0, 62.75)
	EffectsRow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EffectsRow.add_theme_constant_override("separation", 4)
	EffectsRow.name = "EffectsRow"
	add_child(EffectsRow)
	
	var newContainer: Control
	for effect in tile.effects:
		if(effect != Tile.Effect.RAINBOW):
			newContainer = Tile.getEffectContainer(effect, tile.color)
			EffectsRow.add_child(newContainer)
	
	press.connect(GameScene.MainPlayer.tilePressed.bind(self))

func flash(enable: bool) -> void:
	if(enable):
		if(flashTween != null):
			return
		
		flashTween = create_tween()
		FlashingHighlight.self_modulate.a = 0
		flashTween.set_loops()
		flashTween.tween_property(FlashingHighlight, "self_modulate:a", 1, 0.75)
		flashTween.tween_property(FlashingHighlight, "self_modulate:a", 0, 0.75)
		FlashingHighlight.visible = true
	else:
		if(flashTween != null && flashTween.is_running()):
			flashTween.kill()
			flashTween = null
			FlashingHighlight.visible = false

func show_count(index: int) -> void:
	if(index <= -1):
		SpreadSelectionCount.visible = false
		return
	
	SpreadSelectionCount.text = str(index)
	var textSize_X: float = SpreadSelectionCount.get_theme_font("font").get_string_size(str(index)).x
	SpreadSelectionCount.position.x = getSize().x/2 - textSize_X/2
	
	SpreadSelectionCount.visible = true

func getPointsBubble(points: int = -1) -> SparkleContainer:
	if(points == -1):
		points = tile.points
	
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
	pointsLabel.position = -textSize/2
	pointsLabel.z_index = 3
	#pointsLabel.top_level = true
	
	spreadSparkles.add_child(pointsLabel)
	
	return spreadSparkles

#var tempPointsBubbles: Array[SparkleContainer]
static var pointSumBubble: SparkleContainer = null
static var pointSumLabel: Label = null
static var pointSumTween: Tween
static var currPointVal: int
static var currPointSum: int

func activate() -> void:
	var spreadingPlayer: Player
	if(MultiplayerHandler.players.is_empty()):
		spreadingPlayer = GameScene.MainPlayer
	else:
		spreadingPlayer = MultiplayerHandler.getCurrentActivePlayer().playerSpace
	var pointsBubble: SparkleContainer = getPointsBubble(tile.points)
	
	pointsBubble.z_index = 2
	pointsBubble.position = size/2
	
	var radius: Vector2 = (BASE_RESOURCE_SIZE + pointsBubble.size)/2 + Vector2(10, 10)
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
		pointSumBubble.reparent(spreadingPlayer)
		pointSumBubble.position = Vector2(0, -350)
	
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
			pointSumBubble.size = Vector2(10+newVal, 10+newVal)
			pointSumBubble.LowerBound_density = newVal
			pointSumBubble.UpperBound_density = 2*newVal
			var textFontSize: int = 1
			var textSize: Vector2 = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize)
			while(textSize.x <= pointSumBubble.size.x && textSize.y <= pointSumBubble.size.y):
				textFontSize += 1
				textSize = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize)
			
			textFontSize -= 1
			textSize = pointSumLabel.get_theme_font("font").get_string_size("+"+str(newVal), pointSumLabel.horizontal_alignment, -1, textFontSize)
			
			pointSumLabel.add_theme_font_size_override("font_size", textFontSize)
			pointSumLabel.text = "+"+str(newVal)
			pointSumLabel.position = -textSize/2, currPointVal, currPointSum, 0.7)
		
		pointSumTween.finished.connect(func() -> void: spreadingPlayer.spreadFinishCount += 1))

func _mouse_entered() -> void:
	super()
	
	Highlight.visible = true

func _mouse_exited() -> void:
	super()
	
	if(GameScene.MainPlayer.selectedTiles.has(self)):# || (flashTween != null && flashTween.is_running())):
		return
	
	Highlight.visible = false
