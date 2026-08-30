@tool
extends Control

class_name GoodButton

#const PRESS_TIMER_THRESHOLD: float = 0.5
#const TIP_TIMER_TRIGGER: float = 1

const BASE_RESOURCE_SIZE: Vector2 = Vector2(75, 105)

@export_range(0, 3, 0.01, "or_greater", "prefer_slider") var Press_TimerThreshold: float = 0.5
@export_range(0, 3, 0.01, "or_greater", "prefer_slider") var Tip_TimerThreshold: float = 1.0
@export var hasTip: bool = false
@export var enabled: bool = true: set = set_enable
func set_enable(enable: bool):
	if(enable != enabled):
		if(enable):
			if(mouse_inside):
				changeColor(HighlighColor)
				#ButtonIcon.self_modulate = HighlighColor
			else:
				changeColor(color)
				#ButtonIcon.self_modulate = color
		else:
			stillPressingInside = false
			changeColor(DisabledColor)
			#ButtonIcon.self_modulate = DisabledColor
	
	enabled = enable

@export_group("Label")
@export_storage var wasWrapped: bool = false
@export var text: String = "":
	set(newText):
		var textSize: Vector2 = getTextRealSize(newText)
		var isShrinking: bool
		if(wasWrapped):
			isShrinking = textSize.y < getTextRealSize(text).y
		else:
			isShrinking = textSize.x < getTextRealSize(text).x
		
		text = newText
		ButtonText.text = newText
		
		if(Icon_isImage):
			return
		
		var newSize: Vector2 = textSize
		if(!wasWrapped):
			newSize.x *= 1.1
			
			if(newSize.y < custom_minimum_size.y):
				TextBoundSize.y = false
				newSize.y = custom_minimum_size.y
			if(size.y < newSize.y):
				TextBoundSize.y = true
			elif(!TextBoundSize.y):
				newSize.y = size.y
			
			if(newSize.x < custom_minimum_size.x):
				newSize.x = custom_minimum_size.x
			
			if(isShrinking):
				if(newSize.x < size.x && !TextBoundSize.x):
					newSize.x = size.x
			else:
				if(newSize.x >= size.x):
					TextBoundSize.x = true
				else:
					newSize.x = size.x
		else:
			newSize.x = size.x
			
			if(newSize.y < custom_minimum_size.y):
				newSize.y = custom_minimum_size.y
			
			if(isShrinking):
				if(newSize.y < size.y && !TextBoundSize.y):
					newSize.y = size.y
			else:
				if(newSize.y >= size.y):
					TextBoundSize.y = true
				else:
					newSize.y = size.y
		
		size = newSize
		
		ButtonIcon.position = newSize/2
		ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
		
		ButtonText.position = Vector2()
		ButtonText.size = newSize

func getTextRealSize(newText: String, override_maxWidth: float = -1) -> Vector2:
	if(newText.is_empty()):
		return Vector2()
	
	if(!wasWrapped):
		var returnSize: Vector2
		var currString: String = ""
		const escapeChar: String = "\n"
		var lineSize: Vector2
		for charr in newText:
			if(charr == escapeChar):
				lineSize = ButtonText.get_theme_font("font").get_string_size(currString, horizontal_alignment, -1, ButtonText.get_theme_font_size("font_size"), ButtonText.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
				
				if(returnSize.y != 0):
					returnSize.y += ButtonText.get_theme_constant("line_spacing")
				
				returnSize.y += lineSize.y
				if(returnSize.x < lineSize.x):
					returnSize.x = lineSize.x
				
				currString = ""
				continue
			
			currString += charr
		
		lineSize = ButtonText.get_theme_font("font").get_string_size(currString, horizontal_alignment, -1, ButtonText.get_theme_font_size("font_size"), ButtonText.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
		
		if(returnSize.y != 0):
			returnSize.y += ButtonText.get_theme_constant("line_spacing")
		
		returnSize.y += lineSize.y
		if(returnSize.x < lineSize.x):
			returnSize.x = lineSize.x
		
		return returnSize
	else:
		var maxWidth: float = size.x
		if(override_maxWidth >= 0):
			maxWidth = override_maxWidth
		
		var textSize: Vector2 = Vector2(maxWidth, 0)
		var initialSize: Vector2 = ButtonText.get_theme_font("font").get_string_size(newText[0], horizontal_alignment, -1, ButtonText.get_theme_font_size("font_size"), ButtonText.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
		var currWidth: float = initialSize.x
		var currText: String = ""
		var currText_index: int = 0
		var lineHeight: float = initialSize.y#ButtonText.get_theme_font("font").get_string_size("t", horizontal_alignment, -1, ButtonText.get_theme_font_size("font_size"), ButtonText.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL).y
		var lineSpace: int = ButtonText.get_theme_constant("line_spacing")
		
		while(currText_index < newText.length()):
			while(currWidth < maxWidth && currText_index < newText.length()):
				currText += newText[currText_index]
				currText_index += 1
				if(currText_index < newText.length()):
					if(newText[currText_index] == "\n"):
						currText_index += 1
						break
					currWidth = ButtonText.get_theme_font("font").get_string_size(currText+newText[currText_index], horizontal_alignment, -1, ButtonText.get_theme_font_size("font_size"), ButtonText.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL).x
			
			if(textSize.y != 0):
				textSize.y += lineSpace
			
			textSize.y += lineHeight
			currText = ""
			currWidth = 0
		
		
		return textSize

@export var text_wrap: bool = false:
	set(newTextWrap):
		text_wrap = newTextWrap
		wasWrapped = newTextWrap
		if(newTextWrap):
			ButtonText.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		else:
			ButtonText.autowrap_mode = TextServer.AUTOWRAP_OFF
			var newSize: Vector2
			var newTextSize: Vector2 = getTextRealSize(ButtonText.text)
			if(size.x > newTextSize.x):
				TextBoundSize.x = false
				newSize.x = size.x
			else:
				TextBoundSize.x = true
				newSize.x = newTextSize.x
			
			if(TextBoundSize.y):
				newSize.y = newTextSize.y
			else:
				newSize.y = size.y
			
			if(custom_minimum_size.y > newSize.y):
				newSize.y = custom_minimum_size.y
				TextBoundSize.y = false
			
			size = newSize
			
			ButtonIcon.position = newSize/2
			ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
			
			ButtonText.position = Vector2()
			ButtonText.size = newSize
			
			get_tree().create_timer(0.0001).timeout.connect(func() -> void: ButtonText.size = newSize)

@export var text_color: Color = Color.BLACK:
	set(newColor):
		text_color = newColor
		ButtonText.self_modulate = newColor

#@export_storage var wasWrapped: bool = false

@export_enum("Top:0", "Center:1", "Bottom:2") var vertical_alignment = 1:
	set(newVal):
		vertical_alignment = newVal
		ButtonText.vertical_alignment = newVal as VerticalAlignment
@export_enum("Left:0", "Center:1", "Right:2") var horizontal_alignment = 1:
	set(newVal):
		horizontal_alignment = newVal
		ButtonText.horizontal_alignment = newVal as HorizontalAlignment

@export_group("Icon")
@export var image: Texture = null:
	set(newImage):
		image = newImage
		if(newImage == null):
			Icon_isImage = false
			ButtonIcon.texture = CanvasTexture.new()
			return
		
		ButtonIcon.texture = newImage
		
		var newSize: Vector2 = newImage.get_size()
		if(custom_minimum_size.x > newSize.x):
			custom_minimum_size.x = newSize.x
		
		if(custom_minimum_size.y > newSize.y):
			custom_minimum_size.y = newSize.y
		
		size = newSize
		
		ButtonIcon.position = newSize/2
		ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
		
		ButtonText.position = Vector2()
		ButtonText.size = newSize
		
		#color = Color.WHITE
		#HighlighColor = Color.WHITE
		#DisabledColor = Color.WHITE
		#PressedColor = Color.WHITE
		
		Icon_isImage = true
		
		REassignColor()

##The Normal Color of the Button's Background. When this value is changed, the values for the Highlight, Disabled and Pressed Color properties also change, unless they were set manualy.
@export var color: Color = Color.WHITE:
	set(newColor):
		color = newColor
		
		if(!IndependentColors.HighlighColor):
			HighlighColor = color + (Color.WHITE - color)*0.3
		if(!IndependentColors.DisabledColor):
			DisabledColor = Color(color*0.8, color.a)
		if(!IndependentColors.PressedColor):
			PressedColor = Color(color*0.8, color.a)
		
		REassignColor()

var colorTransitionTween: Tween
@export_range(0, 1, 0.01, "prefer_slider") var colorTransitionTime: float = 0.1

func REassignColor() -> void:
	if(enabled):
		if(mouse_inside):
			if(stillPressingInside):
				changeColor(PressedColor)
			else:
				changeColor(HighlighColor)
		else:
			changeColor(color)
	else:
		changeColor(DisabledColor)

func changeColor(newColor: Color) -> void:
	if(colorTransitionTime > 0):
		if(colorTransitionTween != null && colorTransitionTween.is_running()):
			#if(colorTransitionTween.fin)
			#colorTransitionTween.get_loops_left()
			colorTransitionTween.stop()
		
		colorTransitionTween = create_tween()
		colorTransitionTween.tween_property(ButtonIcon, "self_modulate", newColor, colorTransitionTime)
	
	else:
		if(ButtonIcon.self_modulate == newColor):
			return
		
		ButtonIcon.self_modulate = newColor

@export_subgroup("Color Options")
##The Color the Button's Background takes when the mouse hovers over it and is enabled.
@export var HighlighColor: Color:
	set(newColor):
		IndependentColors.HighlighColor = !(newColor == color + (Color.WHITE - color)*0.3)
		HighlighColor = newColor
		
		REassignColor()
##The Color the Button's Background takes when it is not enabled.
@export var DisabledColor: Color = Color(0.8, 0.8, 0.8, 1):
	set(newColor):
		IndependentColors.DisabledColor = !(newColor == Color(color*0.8, color.a))
		DisabledColor = newColor
		
		REassignColor()
##The Color the Button's Background takes when it is pressed and is enabled.
@export var PressedColor: Color = Color(0.8, 0.8, 0.8, 1):
	set(newColor):
		IndependentColors.PressedColor = !(newColor == Color(color*0.8, color.a))
		PressedColor = newColor
		
		REassignColor()

var TextBoundSize: Dictionary = {"x": true, "y": true}
var IndependentColors: Dictionary = {"HighlighColor": false, "DisabledColor": false, "PressedColor": false}

var ButtonText: Label
var ButtonIcon: Sprite2D

var mouse_inside: bool = false
var stillPressingInside: bool = false
var hoverTimer: float = 0
var pressingTimer: float = 0

var TipName: Callable
var TipKeywords: Callable
var TipDescription: Callable

var Tip: UITip
var Icon_isImage: bool = false

#var buttonType: ButtonType = ButtonType.NONE
#
#enum ButtonType{
	#NONE, SPREAD, DISCARD, SENSOR_TILE, SENSOR_JOKER, SENSOR_ITEM, SENSOR_ITEMBAR, REVEAL_MODIFIERS, HIDE_MODIFIERS, BAIT, TRANSITION_BOARD, TRANSITION_SPREAD, TRANSITION_RIVER, EXIT_SHOP
#}

func _set(property: StringName, value: Variant) -> bool:
	if !Engine.is_editor_hint():
		return false
	
	if(property == "custom_minimum_size"):
		if(Icon_isImage):
			var imageSize: Vector2 = image.get_size()
			if(value.x > imageSize.x):
				value.x = imageSize.x
			if(value.y > imageSize.y):
				value.y = imageSize.y
			
			custom_minimum_size = value
			return true
		
		var newSize: Vector2 = value
		var override_sizeValue: Vector2 = size
		var textSize: Vector2 = getTextRealSize(ButtonText.text)#ButtonText.get_theme_font("font").get_string_size(ButtonText.text)
		
		if(newSize.x < override_sizeValue.x):
			newSize.x = override_sizeValue.x
		if(newSize.y < override_sizeValue.y):
			newSize.y = override_sizeValue.y
		
		if(!wasWrapped):
			if(newSize.x > textSize.x):
				TextBoundSize.x = false
			else:#if(value.x <= textSize.x)
				TextBoundSize.x = true
				newSize.x = textSize.x
		else:
			if(newSize.y > textSize.y):
				TextBoundSize.y = false
			else:#if(value.x <= textSize.x)
				TextBoundSize.y = true
				newSize.y = textSize.y
		
		custom_minimum_size = value
		size = newSize
		
		ButtonIcon.position = size/2
		ButtonIcon.region_rect = Rect2(Vector2(0, 0), size)
		
		ButtonText.position = Vector2()
		ButtonText.size = size
		
		return true
	
	if(property == "size"):
		if(Icon_isImage):
			return true
		
		if(value.x < custom_minimum_size.x):
			value.x = custom_minimum_size.x
		
		if(value.y < custom_minimum_size.y):
			value.y = custom_minimum_size.y
		
		var newSize: Vector2 = value
		var textSize: Vector2 = getTextRealSize(ButtonText.text, value.x)#ButtonText.get_theme_font("font").get_string_size(ButtonText.text)
		
		if(!wasWrapped):
			if(newSize.x > textSize.x):
				TextBoundSize.x = false
			else:
				TextBoundSize.x = true
				newSize.x = textSize.x
			
			if(newSize.y <= textSize.y):
				TextBoundSize.y = true
				newSize.y = textSize.y
			else:
				TextBoundSize.y = false
		else:
			if(newSize.y > textSize.y):
				TextBoundSize.y = false
			else:
				TextBoundSize.y = true
				newSize.y = textSize.y
		
		size = newSize
		
		ButtonIcon.position = newSize/2
		ButtonIcon.region_rect = Rect2(Vector2(0, 0), newSize)
		
		ButtonText.position = Vector2()
		ButtonText.size = newSize
		
		return true
	
	return false

func _property_can_revert(property: StringName) -> bool:
	if(property == "HighlighColor" || property == "DisabledColor" || property == "PressedColor"):
		return true
	
	return false

func _property_get_revert(property: StringName) -> Variant:
	if(property == "HighlighColor"):
		return color + (Color.WHITE - color)*0.3
	
	if(property == "DisabledColor"):
		return Color(color*0.8, color.a)
	
	if(property == "PressedColor"):
		return Color(color*0.8, color.a)
	
	return null

func _init(newText: String = "a", IconColor: Color = Color.WHITE, newSize: Vector2 = size, newImage: Texture = null, enable: bool = true, TN: Callable = Callable(), TK: Callable = Callable(), TD: Callable = Callable()) -> void:#----------------------------------------------------------------------------------
	TipName = TN
	TipKeywords = TK
	TipDescription = TD
	
	hasTip = (TN.is_valid() && TK.is_valid() && TD.is_valid())# && (TN.get_argument_count() == 1 && TK.get_argument_count() == 1 && TD.get_argument_count() == 1)
	
	size = newSize
	
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	ButtonIcon = Sprite2D.new()
	ButtonIcon.region_enabled = true
	ButtonIcon.name = "ButtonIcon"
	add_child(ButtonIcon)
	
	ButtonText = Label.new()
	
	var textSize: Vector2 = getTextRealSize(newText)
	if(size.x > textSize.x):
		TextBoundSize.x = false
	if(size.y > textSize.y):
		TextBoundSize.y = false
	
	text = newText
	ButtonText.self_modulate = Color.BLACK
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ButtonText.name = "ButtonText"
	add_child(ButtonText)
	
	image = newImage
	color = IconColor
	
	ButtonIcon.position = size/2
	ButtonIcon.region_rect = Rect2(Vector2(0, 0), size)
	
	ButtonText.position = Vector2()
	ButtonText.size = size
	
	enabled = enable

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		checkHovering(delta)
		checkButtonAction(delta)

func getSize() -> Vector2:
	return size*scale

func checkHovering(delta: float) -> void:
	if(mouse_inside && !stillPressingInside):
		hoverTimer += delta
		
		if(hasTip && hoverTimer >= Tip_TimerThreshold && Tip == null):
			Tip = UITip.new(self)
			Tip.name = "UITip"
			Tip.visible = false
			GameScene.Game.add_child(Tip)
	
	if(Tip != null && !Tip.visible && Tip.resizeComplete):
		Tip.visible = true

func checkButtonAction(delta: float) -> void:
	if(Input.is_action_just_released("Left_Click") && stillPressingInside):
		stillPressingInside = false
		
		if(enabled):
			if(mouse_inside):
				ButtonIcon.self_modulate = HighlighColor
			else:
				ButtonIcon.self_modulate = color
		
		if(pressingTimer <= Press_TimerThreshold):
			finalPress()
		else:
			lateFinalPress()
		
		pressingTimer = 0
	
	if(Input.is_action_pressed("Left_Click") && stillPressingInside):
		pressing(delta)
	
	if(Input.is_action_just_pressed("Left_Click") && mouse_inside):
		initialPress()

func initialPress() -> void:
	if(enabled):
		ButtonIcon.self_modulate = PressedColor
	
	stillPressingInside = true
	
	hoverTimer = 0
	pressingTimer = 0
	
	if(Tip != null && enabled):
		Tip.queue_free()

func pressing(delta: float) -> void:
	pressingTimer += delta

signal press()#button: GoodButton

func finalPress() -> void:
	if(!enabled):
		return
	
	if(Tip != null && enabled):
		Tip.queue_free()
	
	press.emit()

func lateFinalPress() -> void:
	pressingTimer = 0
	
	if(Tip != null && enabled):
		Tip.queue_free()

func _mouse_entered() -> void:
	mouse_inside = true
	hoverTimer = 0
	
	if(enabled):
		ButtonIcon.self_modulate = HighlighColor

func _mouse_exited() -> void:
	mouse_inside = false
	stillPressingInside = false
	
	if(enabled):
		ButtonIcon.self_modulate = color
	
	hoverTimer = 0
	
	if(Tip != null):
		Tip.queue_free()




func getName(TipRef: UITip) -> String:
	var returnVal: String = TipName.call(TipRef)
	return returnVal
	#match buttonType:
		#ButtonType.TRANSITION_BOARD:
			#return StringsManager.UIStrings["CAMERA"]["NAME"][0] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		#ButtonType.TRANSITION_SPREAD:
			#return StringsManager.UIStrings["CAMERA"]["NAME"][1] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		#ButtonType.TRANSITION_RIVER:
			#return StringsManager.UIStrings["CAMERA"]["NAME"][2] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		#ButtonType.SENSOR_TILE:
			#return StringsManager.UIStrings["SENSOR"]["NAME"][0] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		#ButtonType.SENSOR_JOKER:
			#return StringsManager.UIStrings["SENSOR"]["NAME"][1] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		#ButtonType.SENSOR_ITEM:
			#return StringsManager.UIStrings["SENSOR"]["NAME"][2] + StringsManager.UIStrings["SENSOR"]["NAME"][3]
		#ButtonType.SENSOR_ITEMBAR:
			#return StringsManager.UIStrings["SENSOR"]["NAME"][2] + StringsManager.UIStrings["SENSOR"]["NAME"][4]
		#ButtonType.EXIT_SHOP:
			#return StringsManager.UIStrings["EXIT"]["NAME"]
		#_:
			#return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["NAME"]

func getKeywords(TipRef: UITip) -> String:
	var returnVal: String = TipKeywords.call(TipRef)
	return returnVal
	#match buttonType:
		#ButtonType.SPREAD:
			#var selectionSize: int = Player.selectedTiles.size()
			#var keywords: String = str(selectionSize)
			#
			#if(selectionSize == 1):
				#keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][0]
			#else:
				#keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][1]
			#
			#keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][2]
			#
			#var imageScale: float = (UITip.KEYWORD_SIZE_Y-10)/ResourceContainer.BASE_RESOURCE_SIZE.y
			#
			#var extraBBCodeWidth: float = Tip.Keyword_Text.get_theme_font("font").get_string_size(StringsManager.UIStrings["SPREAD"]["KEYWORDS"][6], Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x
			#var origImagePos_X: float = Tip.Keyword_Text.get_theme_font("font").get_string_size(keywords, Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x - extraBBCodeWidth + 10
			#var imagePos_X: float = origImagePos_X
			#var newSequenceImage: TileImage
			#for tile in Player.selectedTiles:
				##(PlayerTurnButton.size.y - BaitButton.size.y)/2)
				#newSequenceImage = TileImage.new(tile.resource)
				#newSequenceImage.scale = Vector2(imageScale, imageScale)
				#newSequenceImage.position = Vector2(imagePos_X, Tip.Keyword_Text.position.y)
				#newSequenceImage.position.y += (UITip.KEYWORD_SIZE_Y - (ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale))/2
				#imagePos_X += ResourceContainer.BASE_RESOURCE_SIZE.y*imageScale + 1
				#Tip.add_child(newSequenceImage)
			#
			#var emptySpace: String = ""
			#while(Tip.Keyword_Text.get_theme_font("font").get_string_size(emptySpace, Tip.Keyword_Text.horizontal_alignment, -1, Tip.Keyword_Text.get_theme_font_size("normal_font_size")).x < imagePos_X-origImagePos_X):
				#emptySpace += " "
			#
			#
			#keywords += emptySpace + StringsManager.UIStrings["SPREAD"]["KEYWORDS"][3]
			#
			#if(GameScene.MainPlayer.SpreadButton.isEnabled):
				#keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][4]
			#else:
				#keywords += StringsManager.UIStrings["SPREAD"]["KEYWORDS"][5]
			#
			#return keywords
		#ButtonType.DISCARD:
			#var selectionSize: int = Player.selectedTiles.size()
			#var keywords: String = str(selectionSize) + "/[color=dark_red]" + str(Player.minMAXTilesToDiscard.x) + "[/color]([color=light_green]" + str(Player.minMAXTilesToDiscard.y) + "[/color]) "
			#return keywords + StringsManager.UIStrings["DISCARD"]["KEYWORDS"]
		#ButtonType.SENSOR_TILE:
			#var slotSize: int = Shop.TileSelections.size()
			#if(slotSize == 0):
				#return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			#
			#var keywords: String = str(slotSize)
			#if(slotSize == 1):
				#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			#
			#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		#ButtonType.SENSOR_JOKER:
			#var slotSize: int = Shop.JokerSelections.size()
			#if(slotSize == 0):
				#return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			#
			#var keywords: String = str(slotSize)
			#if(slotSize == 1):
				#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			#
			#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		#ButtonType.SENSOR_ITEM:
			#var slotSize: int = Shop.ItemSelections.size()
			#if(slotSize == 0):
				#return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][2]
			#
			#var keywords: String = str(slotSize)
			#if(slotSize == 1):
				#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][1]
			#
			#return keywords + StringsManager.UIStrings["SENSOR"]["KEYWORDS"][0]
		#ButtonType.SENSOR_ITEMBAR:
			#var slotSize: int = GameBar.ItemSlots.size()
			#var endString: String = str(slotSize) + " " + StringsManager.ItemStrings["items"]
			#
			#if(slotSize == 0):
				#endString = StringsManager.ItemStrings["no_item"]
			#elif(slotSize == 1):
				#endString = str(slotSize) + StringsManager.ItemStrings["item"]
			#
			#return StringsManager.UIStrings["SENSOR"]["KEYWORDS"][3] + endString
		#ButtonType.BAIT:
			#return StringsManager.UIStrings["BAIT"]["KEYWORDS"][0] + str(River.bait) + StringsManager.UIStrings["BAIT"]["KEYWORDS"][1]
		#ButtonType.TRANSITION_BOARD, ButtonType.TRANSITION_SPREAD, ButtonType.TRANSITION_RIVER:
			#return StringsManager.UIStrings["CAMERA"]["KEYWORD"]
		#ButtonType.EXIT_SHOP:
			#return StringsManager.UIStrings["EXIT"]["KEYWORDS"][0]
		#_:
			#return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["KEYWORDS"][0]

func getDescription(TipRef: UITip) -> String:
	var returnVal: String = TipDescription.call(TipRef)
	return returnVal
	#match buttonType:
		#ButtonType.SPREAD:
			#var strings: Array = StringsManager.UIStrings["SPREAD"]["DESCRIPTION"]
			#var selectionSize: int = Player.selectedTiles.size() 
			#var description: String = strings[0] + str(selectionSize)
			#
			#if(selectionSize == 1):
				#description += strings[1]
			#else:
				#description += strings[2]
			#
			#description += strings[3]
			#
			#match Player.currentSpreadEligibility:
				#Spread_Info.SpreadCheck.ELIGIBLE:
					#description += strings[4]
					#return description
				#Spread_Info.SpreadCheck.SHORT:
					#description += strings[5] + str(3) + strings[6]
				#Spread_Info.SpreadCheck.VAGUE:
					#description += strings[7]
				#Spread_Info.SpreadCheck.NO_PATTERN:
					#description += strings[8]
				#Spread_Info.SpreadCheck.DUPLICATE_COLOR:
					#description += strings[9]
				#Spread_Info.SpreadCheck.TOO_MANY_COLORS:
					#description += strings[10]
				#Spread_Info.SpreadCheck.SEQUENCE_OOB:
					#description += strings[11]
			#
			#description += strings[12]
			#
			#return description
		#ButtonType.DISCARD:
			#var selectionSize: int = Player.selectedTiles.size()
			#var strings: Array = StringsManager.UIStrings["DISCARD"]["DESCRIPTION"]
			#var description: String = strings[0]
			#
			#if(selectionSize == 0):
				#description += strings[1]
			#elif(selectionSize == 1):
				#description += str(selectionSize) + strings[2]
			#else:
				#description += str(selectionSize) + strings[3]
			#
			#description += strings[4] + str(Player.minMAXTilesToDiscard.x)
			#
			#if(Player.minMAXTilesToDiscard.x == 1):
				#description += strings[2]
			#else:
				#description += strings[1]
			#
			#description += strings[5] + str(Player.minMAXTilesToDiscard.y)
			#
			#if(Player.minMAXTilesToDiscard.y == 1):
				#description += strings[2]
			#else:
				#description += strings[3]
			#
			#description += strings[6]
			#
			#if(selectionSize < Player.minMAXTilesToDiscard.x):
				#description += strings[7]
			#elif(BottledNostalgia.NostalgiaUses > 0):
				#description += StringsManager.ItemStrings["Bottled Nostalgia"]["MISCELLANEOUS"][0]
			#else:
				#description += strings[8] + str(selectionSize) + strings[9] + str(1) + strings[10]
			#
			#return description
		#ButtonType.SENSOR_TILE, ButtonType.SENSOR_JOKER, ButtonType.SENSOR_ITEM:
			#if(ButtonType.SENSOR_TILE && Shop.TileSelections.size() >= Shop.MAX_HORIZONTAL_SELECTIONS):
				#return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			#
			#if(ButtonType.SENSOR_JOKER && Shop.JokerSelections.size() >= Shop.MAX_JOKER_SELECTIONS):
				#return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			#
			#if(ButtonType.SENSOR_ITEM && Shop.ItemSelections.size() >= Shop.MAX_HORIZONTAL_SELECTIONS):
				#return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][3]
			#
			#return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][0] + StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][1]
		#ButtonType.SENSOR_ITEMBAR:
			#return StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][0] + StringsManager.UIStrings["SENSOR"]["DESCRIPTION"][2]
		#ButtonType.BAIT:
			#var strings: Array = StringsManager.UIStrings["BAIT"]["DESCRIPTION"]
			#var beaverStrings: Array = StringsManager.ItemStrings["Beaver Teeth"]["MISCELLANEOUS"]
			#var description: String = strings[0]
			#
			#if(River.bait == 0):
				#description += strings[1]
				#return description
			#else:
				#description += str(River.bait) + strings[2]
			#
			#if(River.bait == 1):
				#if(BeaverTeeth.Beaver_Teeth_Activated):
					#description += beaverStrings[0]
				#else:
					#description += strings[3] + strings[4]
			#else:
				#if(BeaverTeeth.Beaver_Teeth_Activated):
					#description += beaverStrings[1]
				#
				#description += strings[3] + str(River.bait) + strings[5]
				#
				#if(BeaverTeeth.Beaver_Teeth_Activated):
					#description += beaverStrings[2]
				#else:
					#description += strings[6]
				#
				#description += strings[7]
			#
			#description += strings[9]
			#
			#description += strings[7]
			#
			#description += strings[10]
			#
			#return description
		#ButtonType.TRANSITION_BOARD:
			#return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][1]
		#ButtonType.TRANSITION_SPREAD:
			#return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][2]
		#ButtonType.TRANSITION_RIVER:
			#return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][3]
		#ButtonType.EXIT_SHOP:
			#return StringsManager.UIStrings["EXIT"]["DESCRIPTION"][0] + StringsManager.UIStrings["SHOP"][0]
		#_:
			#return StringsManager.UIStrings[ButtonType.keys()[buttonType]]["DESCRIPTION"][0]
