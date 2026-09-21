extends GoodButton

class_name Transition

#const IMAGE_SIZE: Vector2 = Vector2(75, 300)

#var LoadingSprite: Sprite2D
var target: Target
var playerID: int

enum Target{
	SPREAD, BOARD, RIVER, P2P
}

func _init(target_i: Target, rotation_i: float, playerID_i: int = -1, imageBig: bool = true, overrideImage: Texture = null) -> void:
	target = target_i
	playerID = playerID_i
	var newImage: Texture
	if(overrideImage == null):
		if(imageBig):
			newImage = load("res://UI/TransitionArrows.png")
		else:
			newImage = load("res://UI/TransitionArrows_small.png")
	else:
		newImage = overrideImage
	
	super("", Color.WHITE, Vector2(-1, -1), newImage)
	hasTip = true
	
	DisabledColor = Color.TRANSPARENT
	
	#ButtonIcon.region_rect.size += Vector2(10, 10)
	#ButtonIcon.material = ShaderMaterial.new()
	#ButtonIcon.material.shader = load("res://shaders/LoadingOutline.gdshader")
	
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
	
	#ButtonIcon.material.set_shader_parameter("loadingTime", hoverTimer)#Time.get_ticks_msec()/1000.0-0.8

var cameraTransitioning: bool = false

func checkHovering(delta: float) -> void:
	super(delta)
	
	if(hoverTimer >= 0.5 && TileContainer.MovingTile != null && !cameraTransitioning):
		cameraTransitioning = true
		screenTransition(target, playerID)

func finalPress() -> void:
	if(!enabled):
		return
	
	super()
	
	#SpreadCameraTransition.buttonType = GoodButton.ButtonType.TRANSITION_BOARD
	#var windowSize: Vector2 = get_viewport_rect().size
	#var tween: Tween = create_tween()
	#tween.tween_property(Camera, "position", Vector2(PlayerSpread.position.x, Board.BOARD_HEIGHT/2 - windowSize.y/2), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	
	screenTransition(target, playerID)

static var camera_isMoving: bool = false

static func screenTransition(camera_target: Target, target_playerID: int) -> void:
	camera_isMoving = true
	
	var tween: Tween = GameScene.Game.create_tween()
	match camera_target:
		Target.SPREAD:
			Player.camera_spread_pos = true
			var playerSpace: Player
			if(Player.camera_player_pos != null):
				playerSpace = Player.camera_player_pos.playerSpace
			else:
				playerSpace = GameScene.MainPlayer
			
			assert(playerSpace != null, "Unkown Player ID! Screen Transition Button couldn't find Player Space.")
			
			if(TileContainer.MovingTile != null):
				TileContainer.MovingTile.reparent(Player.Camera)
			
			var endPos: Vector2 = -264*Vector2(-sin(playerSpace.rotation), cos(playerSpace.rotation))
			tween.tween_property(Player.Camera, "global_position", playerSpace.PlayerSpread.global_position + endPos, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
			if(Player.GameBoard.endPosHighlight != null):
				Player.GameBoard.endPosHighlight.reparent(playerSpace.PlayerSpread)
			
			tween.finished.connect(func() -> void:
				TileContainer.MovingTile.reparent(playerSpace.PlayerSpread))
		Target.BOARD:
			Player.camera_spread_pos = false
			var playerSpace: Player
			if(Player.camera_player_pos != null):
				playerSpace = Player.camera_player_pos.playerSpace
			else:
				playerSpace = GameScene.MainPlayer
			
			assert(playerSpace != null, "Unkown Player ID! Screen Transition Button couldn't find Player Space.")
			
			if(TileContainer.MovingTile != null):
				TileContainer.MovingTile.reparent(Player.Camera)
			
			var endPos: Vector2 = -264*Vector2(-sin(playerSpace.rotation), cos(playerSpace.rotation))
			tween.tween_property(Player.Camera, "global_position", playerSpace.global_position + endPos, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
			if(Player.GameBoard.endPosHighlight != null):
				Player.GameBoard.endPosHighlight.visible = true
				Player.GameBoard.endPosHighlight.reparent(Player.GameBoard)
			
			tween.finished.connect(func() -> void:
				if(TileContainer.MovingTile != null):
					if(Player.camera_player_pos == Board.player_pos):
						TileContainer.MovingTile.reparent(Player.GameBoard)
					else:
						TileContainer.MovingTile.reparent(Player.Camera))
		Target.P2P:
			Player.camera_spread_pos = false
			Player.camera_player_pos = MultiplayerHandler.getPlayer_byID(target_playerID)
			var playerSpace: Player = Player.camera_player_pos.playerSpace
			assert(playerSpace != null, "Unkown Player ID! Screen Transition Button couldn't find Player Space.")
			
			print("HERE0")
			if(TileContainer.MovingTile != null):
				print("HERE1")
				TileContainer.MovingTile.reparent(Player.Camera)
			
			var cameraRadius: float = GameScene.BoardRadius-264
			var endRot: float = GameScene.interPlayer_rotationStep*(MultiplayerHandler.getPlayer_byID(target_playerID).order - MultiplayerHandler.currPlayer.order)
			
			tween.tween_method(func(newRot: float) -> void:
				Player.Camera.rotation = newRot
				Player.Camera.global_position =  cameraRadius*Vector2(sin(-(GameScene.MainPlayer.rotation+newRot)), cos(-(GameScene.MainPlayer.rotation+newRot)))
				, Player.Camera.rotation, endRot, 1)
			
			tween.finished.connect(func() -> void:
				if(TileContainer.MovingTile != null):
					if(Player.camera_player_pos == Board.player_pos):
						TileContainer.MovingTile.reparent(Player.GameBoard))
	
	tween.finished.connect(func() -> void:
		camera_isMoving = false)

static func queue_screenTransition(camera_target: Target, target_playerID: int) -> void:
	while(camera_isMoving):
		await GameScene.Game.get_tree().create_timer(0.001).timeout
	
	screenTransition(camera_target, target_playerID)

func _mouse_exited() -> void:
	super()
	
	cameraTransitioning = false

func getName(_TipRef: UITip) -> String:
	match target:
		Target.BOARD:
			return StringsManager.UIStrings["CAMERA"]["NAME"][0] + StringsManager.UIStrings["CAMERA"]["NAME"][4]
		Target.P2P:
			var nameText: String = StringsManager.UIStrings["CAMERA"]["NAME"][1] + StringsManager.UIStrings["CAMERA"]["NAME"][4] + " ("
			if(playerID == MultiplayerHandler.currPlayer.ID):
				nameText += StringsManager.UIStrings["CAMERA"]["NAME"][5]
			else:
				nameText += MultiplayerHandler.getPlayer_byID(playerID).name
			nameText += ")"
			return nameText
		Target.SPREAD:
			return StringsManager.UIStrings["CAMERA"]["NAME"][2] + StringsManager.UIStrings["CAMERA"]["NAME"][4]
		Target.RIVER:
			return StringsManager.UIStrings["CAMERA"]["NAME"][3] + StringsManager.UIStrings["CAMERA"]["NAME"][4]
	
	return ""

func getKeywords(_TipRef: UITip) -> String:
	return StringsManager.UIStrings["CAMERA"]["KEYWORDS"]

func getDescription(_TipRef: UITip) -> String:
	match target:
		Target.BOARD:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][1]
		Target.P2P:
			var description: String = StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0]
			if(playerID == MultiplayerHandler.currPlayer.ID):
				description += StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][2]
			else:
				description += StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][3] + MultiplayerHandler.getPlayer_byID(playerID).name + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][4]
			return description
		Target.SPREAD:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][5]
		Target.RIVER:
			return StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][0] + StringsManager.UIStrings["CAMERA"]["DESCRIPTION"][6]
	
	return ""
