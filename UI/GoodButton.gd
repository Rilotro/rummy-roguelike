extends Control

class_name GoodButton

const PRESS_TIMER_THRESHOLD: float = 0.5
const TIP_TIMER_TRIGGER: float = 1

var ButtonText: Label
var ButtonIcon: Sprite2D

var mouse_inside: bool = false
var stillPressingInside: bool = false
var hoverTimer: float = 0
var pressingTimer: float = 0
var isEnabled: bool = true
var IconOrigColor: Color
var IconHighlightColor: Color
var IconCurrentColor: Color
var IconDisabledColor: Color
var IconHighlightDisabledColor: Color

var Tip: UITip
var Icon_isImage: bool = false

var buttonType: ButtonType = ButtonType.NONE

enum ButtonType{
	NONE, SPREAD, DISCARD, SENSOR_TILE, SENSOR_JOKER, SENSOR_ITEM, SENSOR_ITEMBAR, REVEAL_MODIFIERS, HIDE_MODIFIERS, BAIT, TRANSITION_BOARD, TRANSITION_SPREAD, TRANSITION_RIVER, EXIT_SHOP
}

func _init(newText: String, IconColor: Color, newButtonType: ButtonType = ButtonType.NONE, newSize: Vector2 = Vector2(-1, -1), newImage: Texture = null, enable: bool = true) -> void:#----------------------------------------------------------------------------------
	buttonType = newButtonType
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	isEnabled = enable
	
	ButtonIcon = Sprite2D.new()
	
	ButtonIcon.name = "ButtonIcon.position"
	add_child(ButtonIcon)
	
	ButtonText = Label.new()
	ButtonText.text = newText
	ButtonText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ButtonText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ButtonText.name = "ButtonText"
	add_child(ButtonText)
	
	if(newImage == null):
		var textSize: Vector2 = ButtonText.get_theme_font("font").get_string_size(newText)
		textSize.x *= 1.1
		
		if(newSize.x < 0):
			newSize.x = textSize.x
	
		if(newSize.y < 0):
			newSize.y = textSize.y
		
		#ButtonText.custom_minimum_size.x 
		
		ButtonIcon.texture = CanvasTexture.new()
		ButtonIcon.self_modulate = IconColor
		ButtonIcon.region_enabled = true
		ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
		
		IconOrigColor = IconColor
		IconCurrentColor = ButtonIcon.self_modulate
		IconHighlightColor = IconColor + (Color.WHITE - IconColor)*0.3
		IconDisabledColor = Color(IconColor*0.8, IconColor.a)
		IconHighlightDisabledColor = IconDisabledColor + (Color.WHITE - IconDisabledColor)*0.3
	else:
		Icon_isImage = true
		ButtonIcon.texture = newImage
		newSize = newImage.get_size()
		
		IconOrigColor = Color.WHITE
		IconHighlightColor = Color.WHITE
		IconCurrentColor = Color.WHITE
		IconDisabledColor = Color.WHITE
		IconHighlightDisabledColor = Color.WHITE
	
	ButtonText.custom_minimum_size = newSize
	custom_minimum_size = newSize
	ButtonIcon.position = newSize/2
	
	if(!isEnabled):
		ButtonIcon.self_modulate -= ButtonIcon.self_modulate*0.2
		ButtonIcon.self_modulate.a = 1

func DIS_ENable(enable: bool) -> void:#, newText: String = ""
	if(isEnabled != enable):
		if(enable):
			ButtonIcon.self_modulate = IconOrigColor
		else:
			ButtonIcon.self_modulate = IconDisabledColor#-= ButtonIcon.self_modulate*0.2
			#ButtonIcon.self_modulate.a = 1
		
		IconCurrentColor = ButtonIcon.self_modulate
	
	isEnabled = enable
	#ButtonText.text = newText
	#ButtonText.custom_minimum_size = ButtonText.get_theme_font("font").get_string_size(newText)
	#custom_minimum_size = ButtonText.custom_minimum_size
	#ButtonIcon.region_rect = Rect2(Vector2(0, 0), ButtonText.custom_minimum_size)
	#ButtonIcon.position = ButtonText.custom_minimum_size/2

##Changes the vidual outlook of the button, including the [param text], [param color], [param size] and [param image].[br]
##NOTE: if you want to remove a button's [param image], [param newImage] must be [code]null[/code] and [param removeImage] must be [code]true[/code].
func changeVisuals(newText: String, newColor: Color = IconOrigColor, newSize: Vector2 = Vector2(-1, -1), newImage: Texture = null, removeImage: bool = false) -> void:
	if(Icon_isImage && newImage == null && !removeImage):
		return
	
	if(newImage != null):
		Icon_isImage = true
		newText = ""
		newSize = newImage.get_size()
		newColor = Color.WHITE
		ButtonIcon.region_enabled = false
		ButtonIcon.texture = newImage
	
	if(Icon_isImage && newImage == null && removeImage):
		Icon_isImage = false
		ButtonIcon.region_enabled = true
		ButtonIcon.texture = CanvasTexture.new()
	
	ButtonText.text = newText
	
	var textSize: Vector2 = ButtonText.get_theme_font("font").get_string_size(newText)
	textSize.x *= 1.1
	
	if(newSize.x == -1):#< textSize.x
		newSize.x = textSize.x
	
	if(newSize.y == -1):#< textSize.y
		newSize.y = textSize.y
	
	custom_minimum_size = newSize
	size = newSize
	
	ButtonText.custom_minimum_size = newSize
	ButtonText.size = newSize
	
	ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
	ButtonIcon.position = newSize/2
	
	IconOrigColor = newColor
	IconCurrentColor = newColor
	IconHighlightColor = newColor + (Color.WHITE - newColor)*0.3
	IconDisabledColor = Color(newColor*0.8, newColor.a)
	IconHighlightDisabledColor = IconDisabledColor + (Color.WHITE - IconDisabledColor)*0.3
	
	if(!isEnabled):
		IconCurrentColor = IconDisabledColor
	
	ButtonIcon.self_modulate = IconCurrentColor

func _process(delta: float) -> void:
	checkHovering(delta)
	checkButtonAction(delta)

func getSize() -> Vector2:
	var unrotatedSize: Vector2 = size*scale
	var size_X: float = unrotatedSize.x*cos(rotation) + unrotatedSize.y*sin(rotation)
	var size_Y: float = unrotatedSize.y*cos(rotation) - unrotatedSize.x*sin(rotation)
	return Vector2(size_X, size_Y)

func getName(Tip: UITip) -> String:
	match buttonType:
		ButtonType.TRANSITION_BOARD:
			return StringsManager.UIStrings["CAMERA"]["NAME"][0] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		ButtonType.TRANSITION_SPREAD:
			return StringsManager.UIStrings["CAMERA"]["NAME"][1] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		ButtonType.TRANSITION_RIVER:
			return StringsManager.UIStrings["CAMERA"]["NAME"][2] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		ButtonType.SENSOR_TILE:
			return StringsManager.UIStrings["SENSOR"]["NAME"][0] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		ButtonType.SENSOR_JOKER:
			return StringsManager.UIStrings["SENSOR"]["NAME"][1] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		ButtonType.SENSOR_ITEM:
			return StringsManager.UIStrings["SENSOR"]["NAME"][2] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		ButtonType.SENSOR_ITEMBAR:
			return StringsManager.UIStrings["SENSOR"]["NAME"][2] + StringsManager.UIStrings["SENSOR"]["NAME"][4]
		ButtonType.EXIT_SHOP:
			return StringsManager.UIStrings["EXIT"]["NAME"]
		_:
			return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["NAME"]

func getKeywords(Tip: UITip) -> String:
	match buttonType:
		ButtonType.SPREAD:
			var selectionSize: int = Player.selectedTiles.size()
			var keywords: String = str(selectionSize)
			
			if(selectionSize == 1):
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][0]
			else:
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][1]
			
			keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][2]
			
			var imageScale: float = (UITip.KEYWORD_SIZE_Y-10)/ResourceContainer.BASE_RESOURCE_SIZE.y
			
			var extraBBCodeWidth: float = Tip.Keyword_Text.get_theme_font("font").get_string_size(StringsManager.UIStrings["SPREAD"]["KEYWORDS"][6], Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x
			var origImagePos_X: float = Tip.Keyword_Text.get_theme_font("font").get_string_size(keywords, Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x - extraBBCodeWidth + 10
			var imagePos_X: float = origImagePos_X
			var newSequenceImage: TileImage
			for tile in Player.selectedTiles:
				#(PlayerTurnButton.size.y - BaitButton.size.y)/2)
				newSequenceImage = TileImage.new(tile.resource)
				newSequenceImage.scale = Vector2(imageScale, imageScale)
				newSequenceImage.position = Vector2(imagePos_X, Tip.Keyword_Text.position.y)
				newSequenceImage.position.y += (UITip.KEYWORD_SIZE_Y - (ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale))/2
				imagePos_X += ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale + 1
				Tip.add_child(newSequenceImage)
			
			var emptySpace: String = ""
			while(Tip.Keyword_Text.get_theme_font("font").get_string_size(emptySpace, Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x < imagePos_X-origImagePos_X):
				emptySpace += " "
			
			
			keywords += emptySpace + StringsManager.UIStrings["SPREAD"]["KEYWORDS"][3]
			
			if(GameScene.MainPlayer.SpreadButton.isEnabled):
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][4]
			else:
				keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][5]
			
			return keywords
		ButtonType.DISCARD:
			var selectionSize: int = Player.selectedTiles.size()
			var keywords: String = str(selectionSize) + "/[color=dark_red]" + str(Player.minMAXTilesToDiscard.x) + "[/color]([color=light_green]" + str(Player.minMAXTilesToDiscard.y) + "[/color]) "
			return keywords + StringsManager.UIStrings["DISCARD"]["KEYWORDS"]
		ButtonType.SENSOR_TILE:
			var slotSize: int = Shop.TileSelections.size()
			if(slotSize == 0):
				return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			
			var keywords: String = str(slotSize)
			if(slotSize == 1):
				return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			
			return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		ButtonType.SENSOR_JOKER:
			var slotSize: int = Shop.JokerSelections.size()
			if(slotSize == 0):
				return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			
			var keywords: String = str(slotSize)
			if(slotSize == 1):
				return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			
			return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		ButtonType.SENSOR_ITEM:
			var slotSize: int = Shop.ItemSelections.size()
			if(slotSize == 0):
				return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			
			var keywords: String = str(slotSize)
			if(slotSize == 1):
				return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			
			return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		ButtonType.SENSOR_ITEMBAR:
			var slotSize: int = GameBar.ItemSlots.size()
			var endString: String = str(slotSize) + " " + StringsManager.ItemStrings["items"]
			
			if(slotSize == 0):
				endString = StringsManager.ItemStrings["no_item"]
			elif(slotSize == 1):
				endString = str(slotSize) + StringsManager.ItemStrings["item"]
			
			return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][3] + endString
		ButtonType.BAIT:
			return StringsManager.UIStrings["BAIT"]["KEYWORDS"][0] + str(River.bait) + StringsManager.UIStrings["BAIT"]["KEYWORDS"][1]
		ButtonType.TRANSITION_BOARD, ButtonType.TRANSITION_SPREAD, ButtonType.TRANSITION_RIVER:
			return StringsManager.UIStrings["CAMERA"]["KEYWORD"]
		ButtonType.EXIT_SHOP:
			return StringsManager.UIStrings["EXIT"]["KEYWORDS"][0]
		_:
			return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["KEYWORDS"][0]

func getDescription(Tip: UITip) -> String:
	match buttonType:
		ButtonType.SPREAD:
			var strings: Array = StringsManager.UIStrings["SPREAD"]["DESCRIPTION"]
			var selectionSize: int = Player.selectedTiles.size() 
			var description: String = strings[0] + str(selectionSize)
			
			if(selectionSize == 1):
				description += strings[1]
			else:
				description += strings[2]
			
			description += strings[3]
			
			match Player.currentSpreadEligibility:
				Spread_Info.SpreadCheck.ELIGIBLE:
					description += strings[4]
					return description
				Spread_Info.SpreadCheck.SHORT:
					description += strings[5] + str(3) + strings[6]
				Spread_Info.SpreadCheck.VAGUE:
					description += strings[7]
				Spread_Info.SpreadCheck.NO_PATTERN:
					description += strings[8]
				Spread_Info.SpreadCheck.DUPLICATE_COLOR:
					description += strings[9]
				Spread_Info.SpreadCheck.TOO_MANY_COLORS:
					description += strings[10]
				Spread_Info.SpreadCheck.SEQUENCE_OOB:
					description += strings[11]
			
			description += strings[12]
			
			return description
		ButtonType.DISCARD:
			var selectionSize: int = Player.selectedTiles.size()
			var strings: Array = StringsManager.UIStrings["DISCARD"]["DESCRIPTION"]
			var description: String = strings[0]
			
			if(selectionSize == 0):
				description += strings[1]
			elif(selectionSize == 1):
				description += str(selectionSize) + strings[2]
			else:
				description += str(selectionSize) + strings[3]
			
			description += strings[4] + str(Player.minMAXTilesToDiscard.x)
			
			if(Player.minMAXTilesToDiscard.x == 1):
				description += strings[2]
			else:
				description += strings[1]
			
			description += strings[5] + str(Player.minMAXTilesToDiscard.y)
			
			if(Player.minMAXTilesToDiscard.y == 1):
				description += strings[2]
			else:
				description += strings[3]
			
			description += strings[6]
			
			if(selectionSize < Player.minMAXTilesToDiscard.x):
				description += strings[7]
			elif(BottledNostalgia.NostalgiaUses > 0):
				description += StringsManager.ItemStrings["Bottled Nostalgia"]["MISCELLANEOUS"][0]
			else:
				description += strings[8] + str(selectionSize) + strings[9] + str(1) + strings[10]
			
			return description
		ButtonType.SENSOR_TILE, ButtonType.SENSOR_JOKER, ButtonType.SENSOR_ITEM:
			if(ButtonType.SENSOR_TILE && Shop.TileSelections.size() >= Shop.MAX_HORIZONTAL_SELECTIONS):
				return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			
			if(ButtonType.SENSOR_JOKER && Shop.JokerSelections.size() >= Shop.MAX_JOKER_SELECTIONS):
				return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			
			if(ButtonType.SENSOR_ITEM && Shop.ItemSelections.size() >= Shop.MAX_HORIZONTAL_SELECTIONS):
				return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			
			return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][0] + StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][1]
		ButtonType.SENSOR_ITEMBAR:
			return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][0] + StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][2]
		ButtonType.BAIT:
			var strings: Array = StringsManager.UIStrings["BAIT"]["DESCRIPTION"]
			var beaverStrings: Array = StringsManager.ItemStrings["Beaver Teeth"]["MISCELLANEOUS"]
			var description: String = strings[0]
			
			if(River.bait == 0):
				description += strings[1]
				return description
			else:
				description += str(River.bait) + strings[2]
			
			if(River.bait == 1):
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[0]
				else:
					description += strings[3] + strings[4]
			else:
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[1]
				
				description += strings[3] + str(River.bait) + strings[5]
				
				if(BeaverTeeth.Beaver_Teeth_Activated):
					description += beaverStrings[2]
				else:
					description += strings[6]
				
				description += strings[7]
			
			description += strings[9]
			
			description += strings[7]
			
			description += strings[10]
			
			return description
		ButtonType.TRANSITION_BOARD:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][1]
		ButtonType.TRANSITION_SPREAD:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][2]
		ButtonType.TRANSITION_RIVER:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][3]
		ButtonType.EXIT_SHOP:
			return StringsManager.UIStrings["EXIT"]["DESCRIPTION"][0] + StringsManager.UIStrings["SHOP"][0]
		_:
			return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["DESCRIPTION"][0]


func checkHovering(delta: float) -> void:
	if(mouse_inside && !stillPressingInside):
		hoverTimer += delta
		
		if(hoverTimer >= TIP_TIMER_TRIGGER && Tip == null):
			Tip = UITip.new(self)
			Tip.name = "UITip"
			Tip.visible = false
			GameScene.Game.add_child(Tip)
	
	if(Tip != null && !Tip.visible && Tip.resizeComplete):
		Tip.visible = true

func checkButtonAction(delta: float) -> void:
	if(Input.is_action_just_released("Left_Click") && stillPressingInside):
		stillPressingInside = false
		if(pressingTimer <= PRESS_TIMER_THRESHOLD):
			finalPress()
		else:
			lateFinalPress()
		
		pressingTimer = 0
	
	if(Input.is_action_pressed("Left_Click") && stillPressingInside):
		pressing(delta)
	
	if(Input.is_action_just_pressed("Left_Click") && mouse_inside):
		initialPress()

func initialPress() -> void:
	stillPressingInside = true
	
	hoverTimer = 0
	pressingTimer = 0
	
	if(Tip != null && isEnabled):
		Tip.queue_free()

func pressing(delta: float) -> void:
	pressingTimer += delta

signal press()#button: GoodButton

func finalPress() -> void:
	if(!isEnabled):
		return
	
	if(Tip != null && isEnabled):
		Tip.queue_free()
	
	press.emit()

func lateFinalPress() -> void:
	pressingTimer = 0
	
	if(Tip != null && isEnabled):
		Tip.queue_free()

func _mouse_entered() -> void:
	mouse_inside = true
	hoverTimer = 0
	
	if(isEnabled):
		ButtonIcon.self_modulate = IconHighlightColor #+= (Color.WHITE - ButtonIcon.self_modulate)*0.3
	else:
		ButtonIcon.self_modulate = IconHighlightDisabledColor

func _mouse_exited() -> void:
	mouse_inside = false
	stillPressingInside = false
	
	ButtonIcon.self_modulate = IconCurrentColor
	
	hoverTimer = 0
	
	if(Tip != null):
		Tip.queue_free()
