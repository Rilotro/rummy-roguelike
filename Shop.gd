extends  Control

class_name Shop

const MAIN_BACKGROUND_COLOR: Color = Color(0, 0.31, 0.53, 1)
const SHOP_TILE_SCALE_REDUCTOR: float = 1.5
const UPGRADE_SEPARATION: float = 20
const FORESIGHT_SEPARATION: float = 10

var Background: Sprite2D
var MainShopBackground: Sprite2D
var UpgradeControl: Control
var ForesightControl: Control
#var ForesightBackground: Sprite2D
var ForesightLabel: RichTextLabel
var ExitShop: GoodButton

static var ForesightCount: int = 5:
	set(newVal):
		ForesightCount = newVal
		
		GameScene.GameShop.reloadForesight()
static var opennedPos: Vector2

func _init() -> void:
	Background = Sprite2D.new()
	Background.texture = CanvasTexture.new()
	Background.region_enabled = true
	Background.self_modulate = Color.BLACK
	Background.self_modulate.a = 100.0/255
	Background.name = "Background"
	add_child(Background)
	
	MainShopBackground = Sprite2D.new()
	MainShopBackground.texture = CanvasTexture.new()
	MainShopBackground.region_enabled = true
	MainShopBackground.self_modulate = MAIN_BACKGROUND_COLOR
	MainShopBackground.name = "MainShopBackground"
	add_child(MainShopBackground)
	
	#UpgradesBackground = Sprite2D.new()
	#UpgradesBackground.texture = CanvasTexture.new()
	#UpgradesBackground.region_enabled = true
	#UpgradesBackground.self_modulate = MAIN_BACKGROUND_COLOR - 0.1*Color.WHITE
	#UpgradesBackground.self_modulate.a = 1
	#UpgradesBackground.name = "UpgradesBackground"
	#add_child(UpgradesBackground)
	#
	#UpgradesBox = HBoxContainer.new()
	#UpgradesBox.size.y = 1.2*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR
	#UpgradesBox.add_theme_constant_override("separation", SELECTION_SEPARATION.x)
	#UpgradesBox.alignment = BoxContainer.ALIGNMENT_CENTER
	#UpgradesBox.name = "UpgradesBox"
	#add_child(UpgradesBox)
	
	UpgradeControl = Control.new()
	UpgradeControl.size.y = TileContainer.BASE_RESOURCE_SIZE.y/SHOP_TILE_SCALE_REDUCTOR
	UpgradeControl.name = "UpgradeControl"
	add_child(UpgradeControl)
	
	ForesightControl = Control.new()
	ForesightControl.size.y = TileContainer.BASE_RESOURCE_SIZE.y/SHOP_TILE_SCALE_REDUCTOR#1.2*
	ForesightControl.name = "ForesightControl"
	add_child(ForesightControl)
	
	#ForesightBackground = Sprite2D.new()
	#ForesightBackground.texture = CanvasTexture.new()
	#ForesightBackground.region_enabled = true
	#ForesightBackground.region_rect.size.y = ForesightControl.size.y
	#ForesightBackground.self_modulate = MAIN_BACKGROUND_COLOR - 0.1*Color.WHITE
	#ForesightBackground.self_modulate.a = 1
	#ForesightBackground.name = "ForesightBackground"
	#add_child(ForesightBackground)
	
	ForesightLabel = RichTextLabel.new()
	ForesightLabel.bbcode_enabled = true
	ForesightLabel.text = StringsManager.UIStrings["SHOP"][5] + str(ForesightCount) + StringsManager.UIStrings["SHOP"][6]
	ForesightLabel.add_theme_font_size_override("normal_font_size", 24)
	ForesightLabel.add_theme_font_size_override("bold_font_size", 24)
	ForesightLabel.name = "ForesightLabel"
	add_child(ForesightLabel)
	
	ExitShop = GoodButton.new("", Color.WHITE, Vector2(-1, -1), load("res://UI/Exit.png"))#, GoodButton.ButtonType.EXIT_SHOP
	ExitShop.scale = Vector2(0.5, 0.5)
	ExitShop.name = "ExitShop"
	add_child(ExitShop)
	
	ExitShop.press.connect(func() -> void:
		var atuuScale: float = GameScene.PlayerBar.Body.region_rect.size.y/(Atuu.BASE_RESOURCE_SIZE.y+Atuu.FRAME_EXTRA_SIZE)
		var finalAtuuPos: Vector2 = -atuuScale*Atuu.BASE_RESOURCE_SIZE/2
		finalAtuuPos.y += Board.BOARD_HEIGHT/2 - get_viewport_rect().size.y + GameScene.PlayerBar.Body.region_rect.size.y/2
		
		var closeTween: Tween = create_tween().set_parallel()
		closeTween.tween_property(self, "scale", Vector2(0, 0), 1)
		closeTween.tween_property(self, "global_position", GameScene.MainPlayer.Camera.global_position, 1)
		closeTween.tween_property(GameScene.MainPlayer.PlayerAtuu, "position", finalAtuuPos, 2)
		closeTween.tween_property(GameScene.MainPlayer.PlayerAtuu, "scale", Vector2(atuuScale, atuuScale), 2)
		closeTween.finished.connect(func() -> void: GameScene.MainPlayer.PlayerAtuu.enabled = true))

#func _ready() -> void:
	#GameScene.MainPlayer.PlayerAtuu.Deck

func window_size_changed() -> void:
	size = GameScene.window_size
	
	Background.region_rect = Rect2(Vector2(0, 0), GameScene.window_size)
	Background.position = GameScene.window_size/2
	
	MainShopBackground.region_rect = Rect2(Vector2(0, 0), GameScene.window_size*0.9)
	MainShopBackground.position = GameScene.window_size/2
	
	UpgradeControl.size.x = MainShopBackground.region_rect.size.x
	UpgradeControl.position.x = GameScene.window_size.x*0.05
	UpgradeControl.position.y = GameScene.window_size.y*0.3
	
	ForesightControl.size.x = GameScene.window_size.x*0.8
	ForesightControl.position.x = GameScene.window_size.x*0.1
	ForesightControl.position.y = GameScene.window_size.y*0.6
	
	ExitShop.position = Vector2(GameScene.window_size.x*0.95 - ExitShop.size.x/2, GameScene.window_size.y*0.05)

#static var upgrades = Array[Tile]

#func reloadShop() -> void:
	#for child in UpgradesBox.get_children():
		#child.queue_free()
	#
	#for child in NextDrawView.get_children():
		#child.queue_free()
	#
	#UpgradesBackground.region_rect.size.x = 0
	#UpgradesBackground.position = UpgradesBox.position + UpgradesBackground.region_rect.size/2
	#
	#NextDrawBackground.region_rect.size = NextDrawView.size
	#NextDrawBackground.position = NextDrawView.position + NextDrawBackground.region_rect.size/2
	#
	#var tilePos: Vector2 = Vector2(SELECTION_SEPARATION.x, 0.1*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR)
	#var tempTile: TileContainer
	#
	#tilePos = Vector2(NEXT_DRAW_SEPARATION.x, 0.1*TileContainer.BASE_RESOURCE_SIZE.y/TILE_IMAGE_SCALE_REDUCTOR)
	#
	#var RowSize: float = DeckViewCount*TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + (DeckViewCount-1)*NEXT_DRAW_SEPARATION.x
	#if(RowSize < NextDrawView.size.x):
		#tilePos.x = (NextDrawView.size.x - RowSize)/2
		#NextDrawBackground.region_rect.size.x = RowSize + NEXT_DRAW_SEPARATION.x * 2
	#
	#nextDrawLabel.text = StringsManager.UIStrings["SHOP"][5] + str(DeckViewCount) + StringsManager.UIStrings["SHOP"][6]
	#nextDrawLabel.size = nextDrawLabel.get_theme_font("normal_font").get_string_size(nextDrawLabel.text, nextDrawLabel.horizontal_alignment, -1, nextDrawLabel.get_theme_font_size("normal_font_size"), nextDrawLabel.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
	#nextDrawLabel.position = NextDrawBackground.position - NextDrawBackground.region_rect.size/2
	#nextDrawLabel.position.y -= nextDrawLabel.size.y
	#
	#if(GameScene.MainPlayer.PlayerAtuu.Deck.size() <= 0):
		#return
	#
	#var deckCount: int = GameScene.MainPlayer.PlayerAtuu.Deck.size()-1
	#for i in range(DeckViewCount):
		#tempTile = TileContainer.new(GameScene.MainPlayer.PlayerAtuu.Deck[deckCount-i], TileContainer.Type.NEXT_DRAW)
		#tempTile.scale /= TILE_IMAGE_SCALE_REDUCTOR
		#tempTile.position = tilePos
		#NextDrawView.add_child(tempTile)
		#
		#tilePos.x += TileContainer.BASE_RESOURCE_SIZE.x/TILE_IMAGE_SCALE_REDUCTOR + NEXT_DRAW_SEPARATION.x

func reloadForesight() -> void:
	ForesightLabel.visible = true
	ForesightLabel.text = StringsManager.UIStrings["SHOP"][5] + str(ForesightCount) + StringsManager.UIStrings["SHOP"][6]
	
	ForesightLabel.size = ForesightLabel.get_theme_font("normal_font").get_string_size(ForesightLabel.text, ForesightLabel.horizontal_alignment, -1, ForesightLabel.get_theme_font_size("normal_font_size"), ForesightLabel.justification_flags, TextServer.DIRECTION_AUTO, TextServer.ORIENTATION_HORIZONTAL)
	ForesightLabel.position = ForesightControl.position
	ForesightLabel.position.y -= ForesightLabel.size.y
	
	for child in ForesightControl.get_children():
		child.queue_free()
	
	var deck_size: int = GameScene.MainPlayer.PlayerAtuu.Deck.size()-1
	var tempCont: TileContainer
	var contPos: Vector2
	contPos.x = ForesightControl.size.x/2
	contPos.x += (ForesightCount-1)*(GoodButton.BASE_RESOURCE_SIZE.x/SHOP_TILE_SCALE_REDUCTOR + FORESIGHT_SEPARATION)/2
	for i in range(ForesightCount):
		tempCont = TileContainer.new(GameScene.MainPlayer.PlayerAtuu.Deck[deck_size-i], TileContainer.Type.FORESIGHT)
		tempCont.scale /= SHOP_TILE_SCALE_REDUCTOR
		tempCont.position = contPos
		tempCont.name = "tempCont" + str(i+1)
		ForesightControl.add_child(tempCont)
		
		contPos.x -= GoodButton.BASE_RESOURCE_SIZE.x/SHOP_TILE_SCALE_REDUCTOR + FORESIGHT_SEPARATION

func toggleForesight(showF: bool = true) -> void:
	ForesightLabel.visible = showF
	
	ForesightControl.visible = showF
	
	for child: TileContainer in UpgradeControl.get_children():
		child.enabled = showF

func addUpgrade(newUpgrade: Tile) -> void:
	#newUpgrade.color = Tile.BASE_COLOR
	newUpgrade.points += Tile.getRarityBasePoints(newUpgrade.rarity)
	
	var upgradeCount: int = UpgradeControl.get_child_count()
	var contPos: Vector2
	contPos.x = UpgradeControl.size.x/2
	contPos.x -= upgradeCount*(GoodButton.BASE_RESOURCE_SIZE.x/SHOP_TILE_SCALE_REDUCTOR + UPGRADE_SEPARATION)/2
	
	for child: TileContainer in UpgradeControl.get_children():
		child.position = contPos
		contPos.x += GoodButton.BASE_RESOURCE_SIZE.x/SHOP_TILE_SCALE_REDUCTOR + UPGRADE_SEPARATION
	
	var newUpgradeCont: TileContainer = TileContainer.new(newUpgrade, TileContainer.Type.UPGRADE)
	newUpgradeCont.custom_minimum_size = TileContainer.BASE_RESOURCE_SIZE
	newUpgradeCont.scale /= SHOP_TILE_SCALE_REDUCTOR
	newUpgradeCont.position = contPos
	newUpgradeCont.name = "newUpgradeCont" + str(upgradeCount+1)
	UpgradeControl.add_child(newUpgradeCont)
