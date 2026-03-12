extends Item

class_name ArchitectsHammer

var isEnding: bool = false

var HammerSprite: Sprite2D

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Architect's Hammer.png")
	uses = 2
	
	consumable = true
	target = ItemTarget.ANY_HIGHLIGHT
	
	super(1, "Architect's Hammer", newGame)

func getDescription() -> String:
	var fullDescription: String = description
	#[b]10 Tile Selections[/b], [b]3 Joker Selections[/b], [b]8 Item Selections[/b] and [b]12 Item Slots[/b])[/color][/font_size]----------------------------------------
	fullDescription += extendedDescription[0]
	
	var MAXsize: Array[int] = [Game.ItemBar.MAX_ITEM_SLOTS, Game.Shop.MAX_TILE_SELECTIONS, Game.Shop.MAX_JOKER_SELECTIONS, Game.Shop.MAX_ITEM_SELECTIONS]
	var currentSize: Array[int] = [Game.ItemBar.ItemSlots.size(), Game.Shop.ItemSelections.size(), Game.Shop.JokerSelections.size(), Game.Shop.ItemSelections.size()]
	
	for i in range(MAXsize.size()):
		if(currentSize[i] >= MAXsize[i]):
			fullDescription += "[color=red]"
		
		fullDescription += "[b]" + str(currentSize[i]) + "/" + str(MAXsize[i])
		
		if(currentSize[i] >= MAXsize[i]):
			fullDescription += "[/b][/color][b]"
		
		fullDescription += " " + extendedDescription[i+1] + "[/b]"
		
		if(i != MAXsize.size()-1):
			fullDescription += ", "
	
	fullDescription += extendedDescription[extendedDescription.size()-1]
	
	return fullDescription

func getShopPrice() -> int:
	return randi_range(15, 30)

func endItemUse(canceled: bool) -> void:
	if(isEnding && canceled):
		return
	
	Game.BG_Obfuscator.visible = false
	Game.ItemBar.ToggleHighlight(false)
	Game.Shop.ToggleHighlight(false, false, false)
	if(canceled):
		HammerSprite.queue_free()
	else:
		HammerSprite = null

func useOnHighlight(Highlight: Control, displacement: Vector2 = Vector2(0, 0)) -> void:
	isEnding = true
	var tempHammer: Sprite2D = HammerSprite
	
	endItemUse(false)
	
	var tween = Game.get_tree().create_tween()
	tween.tween_property(tempHammer, "global_position", Highlight.global_position+displacement, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(tempHammer, "rotation", deg_to_rad(-60), 0.6)
	tween.tween_property(tempHammer, "rotation", deg_to_rad(60), 0.2)
	await tween.finished
	
	await Game.get_tree().create_timer(0.2).timeout
	Game.Shop.visible = false
	#Game.ItemBar.HammerUsed()
	
	tempHammer.queue_free()
	
	Game.endItemUse()
	
	isEnding = false

func use() -> bool:
	if(!Game.getTurn()):
		return false
	
	Game.BG_Obfuscator.visible = true
	Game.ItemBar.ToggleHighlight(true)
	Game.Shop.ToggleHighlight(true, true, true)
	
	HammerSprite = Sprite2D.new()
	HammerSprite.texture = load("res://Items/Sprites/Architect's Hammer.png")
	Game.add_child(HammerSprite)
	#move_child(HammerSprite, 0)
	HammerSprite.z_index = 3
	HammerSprite.global_position = Game.get_global_mouse_position()
	
	Game.TurnButton.text = "Shop"
	
	return true

func updateWhileUsing(delta: float) -> void:
	if(HammerSprite != null):
		HammerSprite.global_position = Game.get_global_mouse_position()
