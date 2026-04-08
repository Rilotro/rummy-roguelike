extends Tile

class_name Partygoer

func _init() -> void:
	super(-1, Color.WHITE, 1)#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	points = 10

func getJokerImage() -> Texture:
	return load("res://Tiles/jokers/Sprites/Partygoer.png")

func getKeywords() -> String:
	return (StringsManager.JokerStrings["joker"]) + " - " + str(points) + " " + StringsManager.EffectStrings["points"]

func getName() -> String:
	return StringsManager.JokerStrings["The Partygoer"]["NAME"]

func getDescription() -> String:
	return StringsManager.JokerStrings["The Partygoer"]["ACTIVATE"] + StringsManager.JokerStrings["The Partygoer"]["DESCRIPTION"]

func getShopPrice() -> int:
	return randi_range(15, 35)

func getOnSpreadEffectsDuration(container: TileContainer) -> float:
	var spreadRow: Array[TileContainer]
	
	for row in GameScene.MainPlayer.PlayerSpread.SpreadRows:
		if(row.Tiles.has(container)):
			spreadRow = row.Tiles
			break
	
	return 0.3*(spreadRow.size()-1)

func activate(container: TileContainer, isPostSpread: bool = false) -> void:
	super(container, isPostSpread)
	#container.pointsGlitter(GameScene.MainPlayer.ExpBar.global_position)
	points += 5
	

func onSpreadEffects(container: TileContainer) -> void:
	activate(container)
	
	await container.get_tree().create_timer(0.3).timeout
	
	var spreadRow: Array[TileContainer]
	
	for row in GameScene.MainPlayer.PlayerSpread.SpreadRows:
		if(row.Tiles.has(container)):
			spreadRow = row.Tiles
			break
	
	for tile in spreadRow:
		if(tile != container):
			activate(container)
			await container.get_tree().create_timer(0.3).timeout
			#tile.pointsGlitter(GameScene.MainPlayer.ExpBar.global_position)
	
	myContainer = GameScene.MainPlayer.PlayerSpread.getTile(self)
	GameScene.MainPlayer.PlayerSpread.getSpreadRow(myContainer).tileActivated_postSpread.connect(func(tileActivated: TileContainer) -> void:
		if(tileActivated != myContainer):
			activate(myContainer, true))
	
