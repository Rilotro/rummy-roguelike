extends Item

class_name BurningShoes

func _init(newGame: GameScene) -> void:
	item_image = load("res://Items/Sprites/Burning Shoes.png")
	
	passive = true
	
	super(5, "Burning Shoes", newGame)
	
	Game.PB.PlayerDraw.connect(effectOnDraw)

func getShopPrice() -> int:
	return randi_range(25, 40)

func getDescription() -> String:
	if(usedThisRound == 0):
		return super()
	else:
		return extendedDescription[0] + str(usedThisRound+1) + extendedDescription[1]

func effectOnGet() -> void:
	Item.singularItems.append(5)
	#Item.flags["Burning Shoes"] += 1

var hasTriggeredEffect: bool = false

func effectOnDraw(_count: int):
	if(Game.ItemBar.getItemSlot(self) == null || hasTriggeredEffect):
		return
	
	while(Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		await Game.get_tree().create_timer(0.01).timeout
	
	while(!Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		await Game.get_tree().create_timer(0.01).timeout
	
	await Game.get_tree().create_timer(0.5).timeout
	
	hasTriggeredEffect = true
	
	Game.PB.Draw(1+usedThisRound)
	
	var tween = Game.get_tree().create_tween()
	Game.PB.BurningDeckSprite.modulate.a = 0
	Game.PB.BurningDeckSprite.visible = true
	tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 1, 0.3)
	await tween.finished
	
	while(!Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		await Game.get_tree().create_timer(0.001).timeout
	
	tween = Game.get_tree().create_tween()
	tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 0, 0.5)
	await tween.finished
	Game.PB.BurningDeckSprite.visible = false
	
	hasTriggeredEffect = false
	usedThisRound += 1
	#---------------------------------------------------------------------------------------------------------------------------
