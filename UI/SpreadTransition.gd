extends GoodButton

class_name Transition

#const IMAGE_SIZE: Vector2 = Vector2(75, 300)

#var LoadingSprite: Sprite2D
var target: Target
var playerID: int

enum Target{
	SPREAD, MAIN_PLAYER, RIVER, OTHER_PLAYER
}

func _init(target_i: Target, rotation_i: float, playerID_i: int = -1, imageBig: bool = true) -> void:
	target = target_i
	playerID = playerID_i
	var newImage: Texture
	if(imageBig):
		newImage = load("res://UI/TransitionArrows.png")
	else:
		newImage = load("res://UI/TransitionArrows_small.png")
	
	super("", Color.TRANSPARENT, Vector2(-1, -1), newImage)
	hasTip = true
	
	HighlighColor = Color.WHITE
	PressedColor = Color.WHITE
	DisabledColor = Color.TRANSPARENT
	
	ButtonIcon.region_rect.size += Vector2(10, 10)
	ButtonIcon.material = ShaderMaterial.new()
	ButtonIcon.material.shader = load("res://shaders/LoadingOutline.gdshader")
	
	rotation = rotation_i

#func _init(target_i: Target, rotation_i: float, imageBig: bool = true) -> void:
	#target = target_i
	#var newImage: Texture
	#if(imageBig):
		#newImage = load("res://UI/TransitionArrows.png")
	#else:
		#newImage = load("res://UI/TransitionArrows_small.png")
	#
	#var arrowImage: Texture = load("res://UI/TrabsitionArraows.png")
	#
	#LoadingSprite = Sprite2D.new()
	#LoadingSprite.texture = CanvasTexture.new()
	#LoadingSprite.region_enabled = true
	#LoadingSprite.region_rect = Rect2(0, 0, 85, 310)
	#LoadingSprite.position = arrowImage.get_size()/2
	#LoadingSprite.self_modulate = Color.YELLOW
	#LoadingSprite.self_modulate.a = 0
	#LoadingSprite.material = ShaderMaterial.new()
	#LoadingSprite.material.shader = load("res://shaders/LoadingOutline.gdshader")
	#LoadingSprite.name = "LoadingSprite"
	#add_child(LoadingSprite)
	
	#super("", Color.WHITE, Vector2(-1, -1), arrowImage)#, GoodButton.ButtonType.TRANSITION_SPREAD

func _process(delta: float) -> void:
	super(delta)
	
	ButtonIcon.material.set_shader_parameter("loadingTime", hoverTimer)#Time.get_ticks_msec()/1000.0-0.8

func getName(_TipRef: UITip) -> String:
	match target:
		Target.MAIN_PLAYER:
			return StringsManager.UIStrings["CAMERA"]["NAME"][0] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3] + " (" + StringsManager.UIStrings["CAMERA"]["NAME"][4] + ")"
		Target.OTHER_PLAYER:
			return StringsManager.UIStrings["CAMERA"]["NAME"][0] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3] + " (" + MultiplayerHandler.getPlayer_byID(playerID).name + ")"
		Target.SPREAD:
			return StringsManager.UIStrings["CAMERA"]["NAME"][1] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
		Target.RIVER:
			return StringsManager.UIStrings["CAMERA"]["NAME"][2] + " " + StringsManager.UIStrings["CAMERA"]["NAME"][3]
	
	return ""

func getKeywords(_TipRef: UITip) -> String:
	return StringsManager.UIStrings["CAMERA"]["KEYWORD"]

func getDescription(_TipRef: UITip) -> String:
	match target:
		Target.MAIN_PLAYER:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][1] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][3]
		Target.OTHER_PLAYER:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + "[b]" + MultiplayerHandler.getPlayer_byID(playerID).name + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][2] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][3]
		Target.SPREAD:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][4]
		Target.RIVER:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][5]
	
	return ""
