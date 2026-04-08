extends Item

class_name BurningShoes

const SPRITE_BASE_PATH: String = "res://Items/Sprites/Burning_Shoes_Sprites/Burning_Shoes_FireDraw_00"
const SPRITE_COUNT: int = 15
const ANIMATION_DURATION: float = 0.35
const SINGLE_SPRITE_DURATION: float = ANIMATION_DURATION/SPRITE_COUNT

func _init() -> void:
	passive = true
	
	super(5)
	
	GameScene.MainPlayer.PlayerDraw.connect(effectOnDraw)

func getImage() -> Texture:
	return load("res://Items/Sprites/Burning Shoes.png")

func getShopPrice() -> int:
	return randi_range(25, 40)

func getIDName() -> String:
	return "Burning Shoes"

func getDescription() -> String:
	var strings: Array = StringsManager.ItemStrings[getIDName()]["DESCRIPTION"]
	var description: String = strings[0]
	if(usedThisRound == 0):
		description += strings[1]
	else:
		description += str(1+usedThisRound) + strings[2]
	
	description += strings[3]
	
	return description

func effectOnGet() -> void:
	Item.singularItems.append(5)
	#Item.flags["Burning Shoes"] += 1

var hasTriggeredEffect: bool = false

func effectOnDraw(fromDeck: bool):
	if(GameScene.PlayerBar.getItemSlot(self) == null || hasTriggeredEffect):#---------------------------------------------------------------------------
		return
	
	if(fromDeck):
		#hasTriggeredEffect = true
		
		#GameScene.MainPlayer.Draw(1+usedThisRound)
		var newTile: TileContainer
		for i in range(usedThisRound+1):
			newTile = TileContainer.new(GameScene.MainPlayer.PlayerDeck.popTile(true), Player.PLAYER_CONTAINER, -1, Player.BOARD_SPACE)
			
			GameScene.MainPlayer.GameBoard.addTile(newTile, Board.TileOrigin.DECK_BURNING_SHOES)
		
		usedThisRound += 1
	else:
		var startingIndex: int = River.river.size()-1
		if(BeaverTeeth.Beaver_Teeth_Activated && BeaverTeeth.chosenRiverTile != null):
			startingIndex = River.river.find(BeaverTeeth.chosenRiverTile)
		
		var burningBait: int = usedThisRound+1
		
		var drawFromDeck: int = burningBait - startingIndex - 1
		if(burningBait > River.river.size() - startingIndex - 1):
			burningBait = River.river.size() - startingIndex - 1
		
		GameScene.MainPlayer.GameRiver.Draw(burningBait, BeaverTeeth.chosenRiverTile)
		
		if(drawFromDeck > 0):
			var newTile: TileContainer
			for i in range(drawFromDeck):
				newTile = TileContainer.new(GameScene.MainPlayer.PlayerDeck.popTile(true), Player.PLAYER_CONTAINER, -1, Player.BOARD_SPACE)
				
				GameScene.MainPlayer.GameBoard.addTile(newTile, Board.TileOrigin.DECK_BURNING_SHOES)
	
	#while(Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		#await Game.get_tree().create_timer(0.01).timeout
	#
	#while(!Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		#await Game.get_tree().create_timer(0.01).timeout
	#
	#await Game.get_tree().create_timer(0.5).timeout
	#
	#hasTriggeredEffect = true
	#
	#Game.PB.Draw(1+usedThisRound)
	#
	#var tween = Game.get_tree().create_tween()
	#Game.PB.BurningDeckSprite.modulate.a = 0
	#Game.PB.BurningDeckSprite.visible = true
	#tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 1, 0.3)
	#await tween.finished
	#
	#while(!Game.PB.Board.TilesCurrentlyDraw.is_empty()):
		#await Game.get_tree().create_timer(0.001).timeout
	#
	#tween = Game.get_tree().create_tween()
	#tween.tween_property(Game.PB.BurningDeckSprite, "modulate:a", 0, 0.5)
	#await tween.finished
	#Game.PB.BurningDeckSprite.visible = false
	#
	#hasTriggeredEffect = false
	#usedThisRound += 1
	#---------------------------------------------------------------------------------------------------------------------------

static func Manage_ButningTile_Sprite(burningTile: Sprite2D, spriteIndex: int) -> void:
	#var spriteIndex: int = ceil(timer/SINGLE_SPRITE_DURATION)
	var SpritePath: String = SPRITE_BASE_PATH
	
	if(spriteIndex < 10):
		SpritePath += "0"
	
	SpritePath += str(spriteIndex) + ".png"
	if(SpritePath != burningTile.texture.load_path):
		burningTile.texture = load(SpritePath)
