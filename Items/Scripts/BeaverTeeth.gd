extends Item

class_name BeaverTeeth

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Beaver Teeth.png")
	
	passive = true
	
	super(4, "Beaver Teeth", newGame)

func getShopPrice() -> int:
	return randi_range(55, 80)

func effectOnGet() -> void:
	Item.singularItems.append(4)
	onGetAnimation()
	
	#Item.flags["Beaver Teeth"] = true
	
	#Game.PB.Beaver()
	Game.PB.River.DT_multiplier = 3
	Game.PB.update_DrainCounter()

func onGetAnimation():
	var tween =  Game.get_tree().create_tween()
	tween.set_parallel()
	for shopUI in Game.Shop.get_children():
		tween.tween_property(shopUI, "modulate:a", 0, 0.5)
	
	var BeaverTeethUp: Sprite2D = Sprite2D.new()
	var BeaverTeethDown: Sprite2D = Sprite2D.new()
	
	BeaverTeethUp.texture = preload("res://Items/Sprites/Beaver_Teeth_UP.png")
	BeaverTeethDown.texture = preload("res://Items/Sprites/Beaver_Teeth_DOWN.png")
	
	Game.Shop.add_child(BeaverTeethUp)
	Game.Shop.add_child(BeaverTeethDown)
	
	BeaverTeethUp.scale = Vector2(0.3, 0.3)
	BeaverTeethDown.scale = Vector2(0.3, 0.3)
	
	var ItemSlot = Game.Shop.getItemSlot(self)
	
	#print(str(ItemSlot) + " - " + str(BeaverTeethUp ) + " - " + str(BeaverTeethDown))
	
	BeaverTeethUp.global_position = ItemSlot.global_position + Vector2(19.5, 30.0)
	BeaverTeethDown.global_position = ItemSlot.global_position + Vector2(19.5, 30.0)
	
	tween.tween_property(BeaverTeethUp, "global_position", Game.PB.get_DrainCounter().global_position + Vector2(0, -25), 0.75)
	tween.tween_property(BeaverTeethUp, "scale", Vector2(0.6, 0.6), 0.4)
	tween.tween_property(BeaverTeethDown, "global_position", Game.PB.get_DrainCounter().global_position + Vector2(0, 25), 0.75)
	tween.tween_property(BeaverTeethDown, "scale", Vector2(0.6, 0.6), 0.4)
	
	await tween.finished
	tween =  Game.get_tree().create_tween()
	
	tween.set_parallel()
	
	tween.tween_property(BeaverTeethUp, "global_position", Game.PB.get_DrainCounter().global_position, 0.01)
	tween.tween_property(BeaverTeethDown, "global_position", Game.PB.get_DrainCounter().global_position, 0.01)
	
	await tween.finished
	
	const BGOrigAlpha: float = 100.0/255.0
	Game.Shop.Shop_BG.self_modulate.a = 1
	Game.Shop.Shop_BG.modulate.a = 1
	await Game.get_tree().create_timer(0.15).timeout
	Game.Shop.Shop_BG.modulate.a = 0
	await Game.get_tree().create_timer(0.075).timeout
	Game.Shop.Shop_BG.modulate.a = 1
	await Game.get_tree().create_timer(0.15).timeout
	
	BeaverTeethUp.queue_free()
	BeaverTeethDown.queue_free()
	
	tween =  Game.get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property(Game.Shop.Shop_BG, "self_modulate:a", BGOrigAlpha, 0.5)
	var first: bool = true
	for shopUI in Game.Shop.get_children():
		if(first):
			first = false
			continue
		tween.tween_property(shopUI, "modulate:a", 1, 0.5)
