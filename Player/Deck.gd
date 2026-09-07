extends GoodButton

#class_name Deck

var DeckTiles: Array[Tile]

var DeacAdd_InteruptionDuration: float = 0

signal TileAdded(tile: TileContainer)

enum TileSource{
	DUPLICATE, SELECTION, SHOP, BOARD
}

func _init() -> void:
	super("", Color.GOLD, ResourceContainer.BASE_RESOURCE_SIZE, null, false)
	hasTip = true
	
	HighlighColor = Color.GOLD
	PressedColor = Color.GOLD
	DisabledColor = Color.WHITE
	
	text_color = Color.BLACK
	horizontal_alignment = 1
	vertical_alignment = 1
	
	text_wrap = true
	
	for i in range(13):
		for tileColor in Tile.COLORS.values():
			DeckTiles.append(Tile.new(i+1, tileColor))#, -1, Tile.Rarity.PORCELAIN, [Tile.Effect.WINGED]))
	
	text = StringsManager.UIStrings["DECK"]["MISCELLANEOUS"][0] + " " + str(DeckTiles.size())
	
	#DeckTiles.append(Joker.new())
	DeckTiles.shuffle()

func _process(delta: float) -> void:
	super(delta)
	
	handleActiveEffects(delta)

func getName(_TipRef: UITip) -> String:
	return StringsManager.UIStrings["DECK"]["NAME"]

func getKeywords(_TipRef: UITip) -> String:
	var keywords: String = StringsManager.UIStrings["DECK"]["KEYWORDS"][0]
	
	if(enabled):
		keywords += ", " + StringsManager.UIStrings["DECK"]["KEYWORDS"][1]
	
	keywords += " - " + str(DeckTiles.size())
	if(DeckTiles.size() == 1):
		keywords += StringsManager.UIStrings["DECK"]["KEYWORDS"][2]
	else:
		keywords += StringsManager.UIStrings["DECK"]["KEYWORDS"][3]
	
	return keywords

func getDescription(_TipRef: UITip) -> String:
	var description: String = StringsManager.UIStrings["DECK"]["DESCRIPTION"][0]
	
	if(DeckTiles.size() == 1):
		description += StringsManager.UIStrings["DECK"]["DESCRIPTION"][1]
	else:
		description +=  str(DeckTiles.size()) + StringsManager.UIStrings["DECK"]["DESCRIPTION"][2]
	
	if(enabled):
		description += StringsManager.UIStrings["DECK"]["DESCRIPTION"][3]
		
		description += StringsManager.UIStrings["DECK"]["DESCRIPTION"][1]
	
	return description

func addTile(newTile: TileContainer, source: TileSource) -> void:
	match source:
		TileSource.DUPLICATE:
			add_child(newTile)
			var duplicateTween: Tween = create_tween()
			duplicateTween.set_parallel()
			duplicateTween.tween_property(newTile, "scale", Vector2(1, 1), 0.3)
			duplicateTween.tween_property(newTile, "modulate:a", 1, 0.3)
			await duplicateTween.finished
			
			TileAdded.emit(newTile)
			var tempDelay: float = DeacAdd_InteruptionDuration
			DeacAdd_InteruptionDuration = 0
			
			duplicateTween = create_tween()
			duplicateTween.set_parallel()
			duplicateTween.tween_property(newTile, "position", Vector2(0, 0), 1).set_delay(tempDelay)
			duplicateTween.tween_property(newTile, "scale", Vector2(0.1, 0.1), 1).set_delay(tempDelay)
			await duplicateTween.finished
			DeckTiles.insert(randi_range(0, DeckTiles.size()-1), newTile.resource)
			newTile.queue_free()
			#var sourceTile: TileContainer = GameScene.Game.PB.PlayerSpread.getTile(newTile)
		TileSource.BOARD:
			newTile.reparent(self)
			
			TileAdded.emit(newTile)
			var tempDelay: float = DeacAdd_InteruptionDuration
			DeacAdd_InteruptionDuration = 0
			
			var boardTween: Tween = create_tween()
			boardTween.set_parallel()
			boardTween.tween_property(newTile, "position", Vector2(0, 0), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(tempDelay)
			boardTween.tween_property(newTile, "scale", Vector2(0.1, 0.1), 1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(tempDelay)
			await boardTween.finished
			DeckTiles.insert(randi_range(0, DeckTiles.size()-1), newTile.resource)
			newTile.queue_free()
		TileSource.SHOP, TileSource.SELECTION:
			#var tileToAdd: Tile = newTile.resource
			var animationTile: TileContainer = TileContainer.new(newTile.tile)
			GameScene.MainPlayer.add_child(animationTile)
			animationTile.global_position = newTile.global_position
			animationTile.z_index = 1
			
			TileAdded.emit(animationTile)
			var tempDelay: float = DeacAdd_InteruptionDuration
			DeacAdd_InteruptionDuration = 0
			
			var animationTween: Tween = create_tween()
			animationTween.set_parallel()
			animationTween.tween_property(animationTile, "position", position+ResourceContainer.BASE_RESOURCE_SIZE/2, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(tempDelay)
			animationTween.tween_property(animationTile, "scale", Vector2(0.1, 0.1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN).set_delay(tempDelay)#------------------------------------------------------------------
			await animationTween.finished
			
			DeckTiles.insert(randi_range(0, DeckTiles.size()-1), animationTile.resource)
			animationTile.queue_free()
		
	
	ButtonText.text = StringsManager.UIStrings["DECK"]["MISCELLANEOUS"][0] + str(DeckTiles.size())

func set_enable(enable: bool):
	super(enable)
	
	if(tween != null):
		tween.stop()

func popTile(fromBack: bool = true, deckPosition: int = -1) -> Tile:
	ButtonText.text = StringsManager.UIStrings["DECK"]["MISCELLANEOUS"][0] + str(DeckTiles.size()-1)
	if(deckPosition >= 0 && deckPosition < DeckTiles.size()-1):
		return DeckTiles.pop_at(deckPosition)
	elif(fromBack):
		return DeckTiles.pop_back()
	else:
		return DeckTiles.pop_front()

var tween: Tween

func handleActiveEffects(_delta: float) -> void:
	if(!enabled):
		return
	
	if(tween == null || !tween.is_running()):
		tween = create_tween()
		tween.tween_property(ButtonIcon, "self_modulate:a", 1-ButtonIcon.self_modulate.a, 1.5)

func finalPress() -> void:
	if(!enabled):
		return
	
	super()
	
	GameScene.Game.StartRound()
	GameScene.MainPlayer.Draw(14)
	
	enabled = false
