extends Modifier

class_name BagOfTiles

func _init(newGame: GameScene) -> void:
	rounds = 2
	type = Type.BOON
	
	image = load("res://Modifiers/Sprites/BagOfTiles.png")
	
	super(newGame)

func effectOnStartOfTurn() -> void:#--------------------------------------------------------------
	Game.select_tiles(SelectScreen.SelectOption.BOARD_ADD_TILE, Vector3i(10, 1, 3), {"EffectsChance": 3})
	
	#while(SelectScreen.finalSelections.is_empty()):
		#await GameScene.Game.get_tree().create_timer(0.001).timeout
	
	#await SelectScreen.sele
	
	
	await Game.tileSelectScreen.selectionEnded
	
	for selection in SelectScreen.Selections:
		if(!SelectScreen.finalSelections.has(selection)):
			GameScene.Game.PB.add_tile_to_deck(selection)
	
	super()
