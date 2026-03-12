extends Item

class_name BurningShoes

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Burning Shoes.png")
	
	passive = true
	
	super(5, "Burning Shoes", newGame)
	
	Game.PB.PlayerDraw.connect(effectOnDraw)

func getShopPrice() -> int:
	return randi_range(25, 40)

func effectOnGet() -> void:
	Item.singularItems.append(5)
	Item.flags["Burning Shoes"] += 1

var hasTriggeredEffect: bool = false

func effectOnDraw(_count: int):
	if(Game.ItemBar.getItemSlot(self) == null || hasTriggeredEffect):
		return
	
	var BurningTile: Tile_Info = Game.PB.Tile_Deck.get(0)
	
	while(Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		await Game.get_tree().create_timer(0.01).timeout
	
	while(!Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		await Game.get_tree().create_timer(0.01).timeout
	
	await Game.get_tree().create_timer(0.5).timeout
	
	hasTriggeredEffect = true
	Game.PB.Draw()
	hasTriggeredEffect = false
	#---------------------------------------------------------------------------------------------------------------------------
	#await Game.PB.Board.TilesCurrentlyDraw.find(BurningTile) >= 0
	while(Game.PB.Board.TilesCurrentlyDraw.find(BurningTile) >= 0):
		await Game.get_tree().create_timer(0.01).timeout
	
	print("HERE3")
	
	var tween = Game.get_tree().create_tween()
	Game.PB.BurningDeckSprite.modulate.a = 0
	Game.PB.BurningDeckSprite.visible = true
	tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 1, 0.3)
	tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 0, 0.5)
	await tween.finished
	Game.PB.BurningDeckSprite.visible = false
	
	#if(Item.flags["Burning Shoes"]):
		#await get_tree().create_timer(1.3 + 0.1*(count-1)).timeout
	#
	#for i in range(Item.flags["Burning Shoes"]):
		#Board.Draw(Tile_Deck[0])
		#Tile_Deck.remove_at(0)
		#$Deck_Counter.text = str(Tile_Deck.size())
		#
		#var tween = get_tree().create_tween()
		#$Deck_Counter/BurningDeck.modulate.a = 0
		#$Deck_Counter/BurningDeck.visible = true
		#tween.tween_property($Deck_Counter/BurningDeck, "modulate:a", 1, 0.3)
		#tween.tween_property($Deck_Counter/BurningDeck, "modulate:a", 0, 0.5)
		#await tween.finished
		#$Deck_Counter/BurningDeck.visible = false
		#if(i < Item.flags["Burning Shoes"]-1):
			#await get_tree().create_timer(1.3).timeout
