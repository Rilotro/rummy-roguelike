extends Item

class_name BeaverTeeth

#[br][font_size=10][color=Gray]If there aren't enough [b]Tiles[/b] to [b]Draw[/b] from the [b]River[/b], [b]Draw[/b] the [i]difference[/i] from the [b]Deck[/b][/color][/font_size]

static var Beaver_Teeth_Activated: bool = false
static var chosenRiverTile: TileContainer = null

func _init() -> void:
	passive = true
	
	super(4)

func getImage() -> Texture:
	return load("res://Items/Sprites/Beaver Teeth.png")

func getIDName() -> String:
	return "Beaver Teeth"

func getShopPrice() -> int:
	return randi_range(55, 80)

func effectOnGet() -> void:
	Beaver_Teeth_Activated = true
	Item.singularItems.append(4)
	onGetAnimation()
	
	#Item.flags["Beaver Teeth"] = true
	
	#Game.PB.Beaver()
	#Game.PB.River.DT_multiplier = 3
	#Game.PB.update_DrainCounter()

func onGetAnimation():
	var tween =  GameScene.Game.get_tree().create_tween()
	tween.set_parallel()
	for shopUI in GameScene.GameShop.get_children():
		tween.tween_property(shopUI, "modulate:a", 0, 0.5)
	
	var BeaverTeethUp: Sprite2D = Sprite2D.new()
	var BeaverTeethDown: Sprite2D = Sprite2D.new()
	
	BeaverTeethUp.texture = preload("res://Items/Sprites/Beaver_Teeth_UP.png")
	BeaverTeethDown.texture = preload("res://Items/Sprites/Beaver_Teeth_DOWN.png")
	
	GameScene.GameShop.add_child(BeaverTeethUp)
	GameScene.GameShop.add_child(BeaverTeethDown)
	
	BeaverTeethUp.scale = Vector2(0.5, 0.5)
	BeaverTeethDown.scale = Vector2(0.5, 0.5)
	
	var ItemSlot: ItemContainer# = GameScene.GameShop#.getItemSlot(self)
	for item in GameScene.GameShop.ItemSelections:
		if(item.resource == self):
			ItemSlot = item
			break
	
	#print(str(ItemSlot) + " - " + str(BeaverTeethUp ) + " - " + str(BeaverTeethDown))
	
	BeaverTeethUp.global_position = ItemSlot.global_position + Vector2(19.5, 30.0)
	BeaverTeethDown.global_position = ItemSlot.global_position + Vector2(19.5, 30.0)
	
	tween.tween_property(BeaverTeethUp, "global_position", GameScene.BaitButton.global_position + GameScene.BaitButton.size/2 + Vector2(0, -25), 0.95)
	tween.tween_property(BeaverTeethUp, "scale", Vector2(1, 1), 0.6)
	tween.tween_property(BeaverTeethDown, "global_position", GameScene.BaitButton.global_position + GameScene.BaitButton.size/2 + Vector2(0, 25), 0.95)#--------------------------------------------------------------------------
	tween.tween_property(BeaverTeethDown, "scale", Vector2(1, 1), 0.6)
	
	await tween.finished
	tween =  GameScene.Game.get_tree().create_tween()
	
	tween.set_parallel()
	
	tween.tween_property(BeaverTeethUp, "global_position", GameScene.BaitButton.global_position + GameScene.BaitButton.size/2, 0.01)
	tween.tween_property(BeaverTeethDown, "global_position", GameScene.BaitButton.global_position + GameScene.BaitButton.size/2, 0.01)
	
	await tween.finished
	
	const BGOrigAlpha: float = 100.0/255.0
	GameScene.GameShop.Background.self_modulate.a = 1
	GameScene.GameShop.Background.modulate.a = 1
	await GameScene.Game.get_tree().create_timer(0.15).timeout
	GameScene.GameShop.Background.modulate.a = 0
	await GameScene.Game.get_tree().create_timer(0.075).timeout
	GameScene.GameShop.Background.modulate.a = 1
	await GameScene.Game.get_tree().create_timer(0.15).timeout
	
	BeaverTeethUp.queue_free()
	BeaverTeethDown.queue_free()
	
	tween =  GameScene.Game.get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(GameScene.GameShop.Background, "self_modulate:a", BGOrigAlpha, 0.5)
	var first: bool = true
	for shopUI in GameScene.GameShop.get_children():
		if(first):
			first = false
			continue
		tween.tween_property(shopUI, "modulate:a", 1, 0.5)
