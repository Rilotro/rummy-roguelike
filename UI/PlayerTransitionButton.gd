#extends Transition
extends Node2D

class_name PlayerTransition

const PLAYER_NAME_FONT_SIZE: int = 32
const PLAYER_TAG_BUTTON_SPACING: float = 5
const BUTTON_SPREAD_VIEW_SPACING: float = 5
const IMAGE_SCALE_SUBTRACTOR: float = 10
const IMAGE_SPACING_X: float = 2

var Body: Sprite2D
var PlayerName: Label
var CameraTransition: Transition

var playerID: int
var miniSpreadControl: Control

func _init(playerID_i: int) -> void:
	playerID = playerID_i
	
	Body = Sprite2D.new()
	Body.texture = CanvasTexture.new()
	Body.self_modulate = Color.DARK_BLUE
	Body.region_enabled = true
	#Body.region_rect.size.y = 48
	Body.name = "Body"
	add_child(Body)
	
	PlayerName = Label.new()
	PlayerName.add_theme_font_size_override("font_size", PLAYER_NAME_FONT_SIZE)
	PlayerName.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PlayerName.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if(playerID == MultiplayerHandler.currPlayer.ID):
		PlayerName.text = "Go Back"
	else:
		PlayerName.text = MultiplayerHandler.getPlayer_byID(playerID_i).name
	PlayerName.name = "PlayerName"
	add_child(PlayerName)
	
	var textSize_x: float = PlayerName.get_theme_font("font").get_string_size(PlayerName.text, PlayerName.horizontal_alignment, -1, PlayerName.get_theme_font_size("font_size"), PlayerName.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL).x*1.1
	
	CameraTransition = Transition.new(Transition.Target.P2P, 0, playerID_i, true, load("res://UI/PlayerArrows.png"))
	CameraTransition.position.x = textSize_x + PLAYER_TAG_BUTTON_SPACING# + CameraTransition.size.x
	CameraTransition.name = "CameraTransition"
	add_child(CameraTransition)
	
	Body.region_rect.size = Vector2(textSize_x, CameraTransition.size.y)
	Body.position = Body.region_rect.size/2
	
	PlayerName.size = Vector2(textSize_x, CameraTransition.size.y)

func miniSpreadView(spreadRow: Array[TileContainer]) -> void:
	miniSpreadControl = Control.new()
	miniSpreadControl.position.x = Body.region_rect.size.x + CameraTransition.size.x + PLAYER_TAG_BUTTON_SPACING + BUTTON_SPREAD_VIEW_SPACING
	miniSpreadControl.position.y = IMAGE_SCALE_SUBTRACTOR/2
	miniSpreadControl.name = "miniSpreadControl"
	add_child(miniSpreadControl)
	
	var spreadImages: Array[TileImage]
	var tempImage: TileImage
	var imageScale: float = (CameraTransition.size.y-IMAGE_SCALE_SUBTRACTOR)/TileContainer.BASE_RESOURCE_SIZE.y
	var interImageSpace: float = TileContainer.BASE_RESOURCE_SIZE.x*imageScale + IMAGE_SPACING_X
	var imageCount: int = 0
	var miniSpreadTween: Tween = create_tween()
	miniSpreadTween.set_parallel().set_trans(Tween.TRANS_QUINT)#.set_ease(Tween.EASE_OUT)
	
	for tile in spreadRow:
		tempImage = TileImage.new(tile.tile)
		tempImage.scale = Vector2(imageScale, imageScale)
		tempImage.position = Vector2(-CameraTransition.size.x, 0)
		miniSpreadControl.add_child(tempImage)
		tempImage.name = "tempImage" + str(imageCount+1)
		spreadImages.append(tempImage)
		
		miniSpreadTween.tween_property(tempImage, "position:x", interImageSpace*imageCount, 0.3).set_delay(0.1*imageCount)
		imageCount += 1
	
	await miniSpreadTween.finished
	
	TileImage.pointBubbleScaleFactor = 2
	TileImage.activateFinished = 0
	var rowLength: float = interImageSpace*imageCount - IMAGE_SPACING_X
	
	for image in spreadImages:
		await image.activate(rowLength/2)
	
	while(TileImage.activateFinished < spreadImages.size()):
		await get_tree().create_timer(0.001).timeout
	
	TileImage.pointSumBubble.z_index = -1
	create_tween().tween_property(TileImage.pointSumBubble, "global_position", global_position + Body.region_rect.size/2, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).finished.connect(func() -> void:
		TileImage.pointSumBubble.queue_free()
		TileImage.pointBubbleScaleFactor = 1
		TileImage.activateFinished = 0
		
		var newMiniSpreadTween = create_tween()
		var newImageCount: int = 0
		var tweenSpeed: float = -Body.region_rect.size.x/0.4
		newMiniSpreadTween.set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		
		for tile in spreadImages:
			newMiniSpreadTween.tween_property(tile, "position:x", -Body.region_rect.size.x, (tile.position.x-Body.region_rect.size.x)/tweenSpeed).set_delay(0.1*newImageCount)
			newMiniSpreadTween.tween_property(tile, "modulate:a", 0, (tile.position.x-Body.region_rect.size.x)/tweenSpeed).set_delay(0.1*newImageCount)
			newImageCount += 1
		
		newMiniSpreadTween.finished.connect(func() -> void:
			for tile in spreadImages:
				tile.queue_free()))
