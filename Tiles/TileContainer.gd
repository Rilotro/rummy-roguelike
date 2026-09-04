@warning_ignore("missing_tool")
extends GoodButton

class_name TileContainer

const HIGHLIGHT_EXPANDED_SIZE: Vector2 = BASE_RESOURCE_SIZE + Vector2(10, 10)
const HIGHLIGHT_BASE_COLOR: Color = Color.GREEN
const HIGHLIGHT_DISCARD_COLOR: Color = Color.RED
const PRESSING_TIMER_THRESHOLD: float = 0.5

var Highlight: Sprite2D
var FlashingHighlight: Sprite2D
var SpreadSelectionCount: Label
var EffectsRow: HBoxContainer
var flashTween: Tween = null

var tile: Tile
var type: Type

enum Type{
	BOARD, NEXT_DRAW, SELECTION
}

func set_enable(enable: bool):
	super(enable)
	
	if(!enable):
		Highlight.visible = false
	
	if(type == Type.SELECTION):
		if(enable):
			modulate = Color(1, 1, 1)
		else:
			modulate = Color(0.7, 0.7, 0.7)

func _init(t: Tile, ty: Type = Type.BOARD) -> void:
	if(t == null):
		t = Tile.getRandomTile()
	
	tile = t
	type = ty
	
	#if(type != Type.BOARD):
		#tile.color = Tile.BASE_COLOR
	
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
	var containerText: String = "\n"
	
	if(type == Type.SELECTION):
		if(tile.points - Tile.getRarityBasePoints(tile.rarity) > 0):
			containerText = "+" + str(tile.points - Tile.getRarityBasePoints(tile.rarity)) + "\n"
	else:
		containerText = str(tile.number)+"\n"
	
	super(containerText, containerColor, BASE_RESOURCE_SIZE, null, true, generateTitle, generateTag, generateDescription)#, tile.getJokerImage(), true, tile.getName ,tile.getKeywords ,tile.getDescription)
	ButtonText.add_theme_font_size_override("font_size", 36)
	text_color = tile.color
	HighlighColor = containerColor
	DisabledColor = containerColor
	PressedColor = containerColor
	
	if(type == Type.NEXT_DRAW):
		enabled = false
		ButtonText.visible = false
	
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

const ARROW_SCALE: float = 25

var isMoving: bool = false
static var selectionArrow: Sprite2D
static var hoveredByArrow: TileContainer = null

func pressing(delta: float) -> void:
	super(delta)
	
	if(pressingTimer >= PRESSING_TIMER_THRESHOLD):
		match type:
			Type.NEXT_DRAW:
				return
			Type.BOARD:
				global_position = get_global_mouse_position() - BASE_RESOURCE_SIZE/2
				isMoving = true
				z_index = 1
				GameScene.MainPlayer.GameBoard.HighlightMovingTileFinalPos(self)
			Type.SELECTION:
				isMoving = true
				if(selectionArrow == null):
					selectionArrow = Sprite2D.new()
					selectionArrow.texture = CanvasTexture.new()
					selectionArrow.scale *= ARROW_SCALE
					selectionArrow.self_modulate = Color.BLACK
					selectionArrow.z_index = 2
					selectionArrow.material = ShaderMaterial.new()
					(selectionArrow.material as ShaderMaterial).shader = load("res://shaders/Arrow.gdshader")
					selectionArrow.name = "selectionArrow"
					GameScene.GameShop.add_child(selectionArrow)
					
					for child in GameScene.GameShop.NextDrawView.get_children():
						(child as TileContainer).enabled = true
				
				var mousePos: Vector2 = get_global_mouse_position()
				selectionArrow.rotation = (global_position + size/2).angle_to_point(mousePos) + PI/2
				selectionArrow.global_position = mousePos + (ARROW_SCALE/2)*Vector2(-sin(selectionArrow.rotation), cos(selectionArrow.rotation))

func lateFinalPress() -> void:
	super()
	
	if(isMoving):
		isMoving = false
		z_index = 0
		match type:
			Type.BOARD:
				GameScene.MainPlayer.GameBoard.endMovement(self)
			Type.SELECTION:
				if(selectionArrow != null):
					selectionArrow.queue_free()
					for child in GameScene.GameShop.NextDrawView.get_children():
						(child as TileContainer).enabled = false
					
					if(hoveredByArrow != null):
						enabled = false
						
						hoveredByArrow.shopUpgrade(tile)
					
					hoveredByArrow = null

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

func shopUpgrade(tileUpgrade: Tile) -> void:
	if(Tile.getRarityBasePoints(tile.rarity) < Tile.getRarityBasePoints(tileUpgrade.rarity)):
		tile.rarity = tileUpgrade.rarity
		color = Tile.getRarityColor(tile.rarity)
		HighlighColor = color
		DisabledColor = color
		PressedColor = color
	
	tile.points += tileUpgrade.getBonusPoints()
	
	if(type == Type.NEXT_DRAW && tile.getBonusPoints() > 0):
		text_color = Color.BLACK
		ButtonText.visible = true
		ButtonText.text = "+" + str(tile.getBonusPoints()) + "\n"

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

func generateTitle(_TipRef: UITip) -> String:
	var title: String = StringsManager.EffectStrings["tile"]
	
	match type:
		Type.BOARD:
			var colorName: String = Tile.COLOR_NAMES[Tile.COLORS.find(tile.color)]
			title += "(" + str(tile.number) + ", [color=" + colorName + "]" + StringsManager.EffectStrings["color"][colorName] + "[/color])"
		Type.SELECTION, Type.NEXT_DRAW:
			title += "([color=" + Tile.getRarityColor(tile.rarity).to_html() + "]" + StringsManager.EffectStrings["rarity"][Tile.Rarity.keys()[tile.rarity]] + "[/color]"
			if(tile.getBonusPoints() > 0):
				title += ", [color=gold]+" + str(tile.getBonusPoints()) + " " + StringsManager.EffectStrings["points"] + "[/color])"
			else:
				title += ")"
	
	return title

func generateTag(_TipRef: UITip) -> String:
	var tag: String = StringsManager.EffectStrings["tile"]
	
	match type:
		Type.BOARD:
			tag += " - [color=" + Tile.getRarityColor(tile.rarity).to_html() + "]" + StringsManager.EffectStrings["rarity"][Tile.Rarity.keys()[tile.rarity]] + "[/color]" + " - [color=gold]" + str(tile.points) + " " + StringsManager.EffectStrings["points"] + "[/color]"
		Type.SELECTION:
			tag += " " + StringsManager.EffectStrings["upgrade"]
		Type.NEXT_DRAW:
			tag = StringsManager.EffectStrings["deck"] + " " + tag
	
	return tag

func generateDescription(_TipRef: UITip) -> String:
	var description: String = ""
	
	match type:
		Type.BOARD:
			description += StringsManager.EffectStrings["DESCRIPTION"][0] + "\n\n" + StringsManager.EffectStrings["ACTIVATE"][0] + str(tile.points) + StringsManager.EffectStrings["ACTIVATE"][1]
		Type.SELECTION:
			description += StringsManager.EffectStrings["DESCRIPTION"][1] + "\n\n" + StringsManager.EffectStrings["DESCRIPTION"][2]
			var upgradeCount: int = 0
			var upgradeIndex: int = 0
			var upgrades: Array[bool]
			
			upgrades.resize(2)
			upgrades.fill(false)
			if(tile.getBonusPoints() > 0):
				upgrades[0] = true
				upgradeCount += 1
			
			if(tile.rarity != Tile.Rarity.PORCELAIN):
				upgrades[1] = true
				upgradeCount += 1
			
			if(upgrades[0]):
				description += StringsManager.EffectStrings["DESCRIPTION"][3] + str(tile.getBonusPoints()) + "[/color]"
				upgradeIndex += 1
			
			if(upgrades[1]):
				if(upgradeIndex == upgradeCount-1 && upgradeCount > 1):
					description += " and "
				elif(upgradeIndex != 0):
					description += ", "
				
				description += StringsManager.EffectStrings["DESCRIPTION"][4] + "[color=" + Tile.getRarityColor(tile.rarity).to_html() + "]" + StringsManager.EffectStrings["rarity"][Tile.Rarity.keys()[tile.rarity]] + "[/color]"
				upgradeIndex += 1
			
			description += "."
		Type.NEXT_DRAW:
			description += StringsManager.EffectStrings["DESCRIPTION"][5]
			
			var deckIndex: int = GameScene.MainPlayer.PlayerDeck.DeckTiles.size() - GameScene.MainPlayer.PlayerDeck.DeckTiles.find(tile)
			if(deckIndex == 1):
				description += StringsManager.UIStrings["ORDINAL_INDICATOR"][4]
			elif(deckIndex == 2):
				description += StringsManager.UIStrings["ORDINAL_INDICATOR"][6]
			else:
				description += str(deckIndex)
				if(deckIndex == 3):
					description += StringsManager.UIStrings["ORDINAL_INDICATOR"][2]
				else:
					description += StringsManager.UIStrings["ORDINAL_INDICATOR"][3]
			
			description += StringsManager.EffectStrings["DESCRIPTION"][6]
	
	return description

func _mouse_entered() -> void:
	super()
	
	if(!enabled):
		return
	
	if(type == Type.NEXT_DRAW):
		if(Input.is_action_pressed("Left_Click") && selectionArrow != null):
			hoveredByArrow = self
	
	Highlight.visible = true

func _mouse_exited() -> void:
	super()
	
	if(!enabled):
		return
	
	if(hoveredByArrow == self):
		hoveredByArrow = null
	
	#if(type == Type.NEXT_DRAW):
		#return
	
	if(isMoving):
		pressStillValid = true
	
	if(GameScene.MainPlayer.selectedTiles.has(self)):
		return
	
	Highlight.visible = false
