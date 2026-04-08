extends Item

class_name ArchitectsHammer

const FULL_SELECTION_COLOR: String = "dark_red"
const NORMAL_SELECTION_COLOR: String = "gray"

var isEnding: bool = false

var HammerSprite: Sprite2D

func _init() -> void:
	uses = 20
	
	consumable = true
	target = ItemTarget.ANY_HIGHLIGHT
	
	super(1)

func getImage() -> Texture:
	return load("res://Items/Sprites/Architect's Hammer.png")

func getIDName() -> String:
	return "Architect's Hammer"

func getDescription() -> String:
	var strings: Array = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]
	var description: String = strings[0] + str(Shop.MAX_HORIZONTAL_SELECTIONS) + strings[1]
	
	var tileSelectionsCount: int = Shop.TileSelections.size()
	var jokerSelectionsCount: int = Shop.JokerSelections.size()
	var itemSelectionsCount: int = Shop.ItemSelections.size()
	
	if(tileSelectionsCount >= Shop.MAX_HORIZONTAL_SELECTIONS):
		description += FULL_SELECTION_COLOR
	else:
		description += NORMAL_SELECTION_COLOR
	
	description += strings[2] + "(" + str(tileSelectionsCount) + "/" + str(Shop.MAX_HORIZONTAL_SELECTIONS) + ")" + strings[3]
	
	if(itemSelectionsCount >= Shop.MAX_HORIZONTAL_SELECTIONS):
		description += FULL_SELECTION_COLOR
	else:
		description += NORMAL_SELECTION_COLOR
	
	description += strings[4] + "(" + str(itemSelectionsCount) + "/" + str(Shop.MAX_HORIZONTAL_SELECTIONS) + ")"  + strings[5] + str(Shop.MAX_JOKER_SELECTIONS) + strings[1]
	
	if(jokerSelectionsCount >= Shop.MAX_JOKER_SELECTIONS):
		description += FULL_SELECTION_COLOR
	else:
		description += NORMAL_SELECTION_COLOR
	
	description += strings[6] + "(" + str(jokerSelectionsCount) + "/" + str(Shop.MAX_JOKER_SELECTIONS) + ")"  + strings[7]
	
	return description

func getShopPrice() -> int:
	return randi_range(15, 30)

func endItemUse(canceled: bool) -> void:
	if(isEnding && canceled):
		return
	
	GameScene.bgObfuscator.visible = false
	GameScene.PlayerBar.ToggleHighlight(false)
	GameScene.GameShop.ToggleHighlight(false)
	GameScene.PlayerTurnButton.changeButtonAction(TurnButton.ButtonAction.END_TURN)
	if(canceled):
		HammerSprite.queue_free()
	else:
		HammerSprite = null

func useOnHighlight(Highlight: GoodButton, displacement: Vector2 = Vector2(0, 0)) -> void:
	isEnding = true
	var tempHammer: Sprite2D = HammerSprite
	
	endItemUse(false)
	
	var tween = GameScene.Game.get_tree().create_tween()
	tween.tween_property(tempHammer, "global_position", Highlight.global_position+displacement, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)#------------------------------------------------------------------------
	tween.tween_property(tempHammer, "rotation", deg_to_rad(-60), 0.6)
	tween.tween_property(tempHammer, "rotation", deg_to_rad(60), 0.2)
	await tween.finished
	
	extended_useOnHighlight(tempHammer)
	
	#await Game.get_tree().create_timer(0.2).timeout
	#Game.Shop.visible = false
	##Game.ItemBar.HammerUsed()
	#
	#tempHammer.queue_free()
	#
	#GameScene.endItemUse()
	#
	#isEnding = false

func extended_useOnHighlight(tempHammer: Sprite2D) -> void:
	await GameScene.Game.get_tree().create_timer(0.2).timeout
	GameScene.GameShop.visible = false
	#Game.ItemBar.HammerUsed()
	
	
	tempHammer.queue_free()
	
	GameScene.PlayerBar.endItemUse(GameScene.usingItem)
	
	isEnding = false

func use() -> bool:
	if(!GameScene.myTurn):
		return false
	
	GameScene.bgObfuscator.visible = true
	GameScene.PlayerBar.ToggleHighlight(true)
	GameScene.GameShop.ToggleHighlight(true)
	#Game.Shop.ToggleHighlight(true, true, true)
	
	HammerSprite = Sprite2D.new()
	HammerSprite.texture = load("res://Items/Sprites/Architect's Hammer.png")
	GameScene.Game.add_child(HammerSprite)
	#move_child(HammerSprite, 0)
	HammerSprite.z_index = 3
	HammerSprite.global_position = GameScene.Game.get_global_mouse_position()
	
	GameScene.PlayerTurnButton.changeButtonAction(TurnButton.ButtonAction.SHOP)
	#Game.TurnButton.text = "Shop"
	
	return true

func updateWhileUsing(_delta: float) -> void:
	if(HammerSprite != null):
		HammerSprite.global_position = GameScene.Game.get_global_mouse_position()
