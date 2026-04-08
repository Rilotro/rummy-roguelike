extends Item

class_name ArchitectsChisel

const RARIFY_DELAY: float = 1

func _init() -> void:
	uses = 5
	
	passive = true
	consumable = true
	
	super(8)
	
	GameScene.MainPlayer.PlayerDeck.TileAdded.connect(EffectOnDeckAddTile)
	#GameScene.Game.PB.DeckAddTile.connect(EffectOnDeckAddTile)#---------------------------------------------------------------------------------------------------------------------------

func getImage() -> Texture:
	return load("res://Items/Sprites/Architect's Chisel.png")

func getIDName() -> String:
	return "Architect's Chisel"

func getDescription() -> String:
	var strings: Array = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]
	var description: String = strings[0]
	if(uses == 1):
		description += strings[1] + strings[2]
	else:
		description += str(uses) + " " + strings[1] + strings[3]
	
	description += strings[4]
	
	return description

func getShopPrice() -> int:
	return randi_range(1, 2)

func EffectOnDeckAddTile(tile: TileContainer):
	if(GameScene.PlayerBar.getItemSlot(self) == null || tile == null):
		return
	
	if(tile.resource.joker_id >= 0 || tile.resource.rarity == Tile.Rarity.GOLD):
		return
	
	#while(tile.is_being_moved):
		#await Game.get_tree().create_timer(0.001).timeout
	
	GameScene.MainPlayer.PlayerDeck.DeacAdd_InteruptionDuration += RARIFY_DELAY
	
	var tempImage: TileImage = TileImage.new(tile.resource)
	tempImage.clip_contents = true
	tile.add_child(tempImage)
	
	var transitionSparkles: SparkleContainer = SparkleContainer.new(Vector2(5, 10))
	transitionSparkles.position = Vector2((ResourceContainer.BASE_RESOURCE_SIZE.x+5)/2, ResourceContainer.BASE_RESOURCE_SIZE.y)
	tile.add_child(transitionSparkles)
	
	tile.resource.Rarify(true)
	tile.REgenerateResource(tile.resource)
	
	var transitionTween: Tween = tile.create_tween()
	
	transitionTween.tween_property(transitionSparkles, "size:x", ResourceContainer.BASE_RESOURCE_SIZE.x+5, 0.1*RARIFY_DELAY).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	await transitionTween.finished
	
	var tempSize: float = tempImage.custom_minimum_size.y
	tempImage.custom_minimum_size.y = 0
	tempImage.size.y = tempSize
	
	var textPos: Vector2 = tempImage.TileNumber.position
	
	transitionTween = tile.create_tween()
	transitionTween.set_parallel()
	transitionTween.set_trans(Tween.TRANS_QUINT)
	transitionTween.set_ease(Tween.EASE_IN_OUT)
	transitionTween.tween_property(transitionSparkles, "position:y", 0, 0.8*RARIFY_DELAY)
	#transitionTween.tween_property(tempImage, "size:y", 0, 0.8*RARIFY_DELAY)
	transitionTween.tween_method(func(newSize: float) -> void:
		tempImage.size.y = newSize
		tempImage.TileNumber.position = textPos,
		ResourceContainer.BASE_RESOURCE_SIZE.y, 0, 0.8*RARIFY_DELAY)
	
	await transitionTween.finished
	tempImage.queue_free()
	transitionTween = tile.create_tween()
	transitionTween.tween_property(transitionSparkles, "size:x", 5, 0.1*RARIFY_DELAY).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
	await transitionTween.finished
	transitionSparkles.queue_free()
	
	GameScene.PlayerBar.usedPassiveItem(GameScene.PlayerBar.getItemSlot(self))
