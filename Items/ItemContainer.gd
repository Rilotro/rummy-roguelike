extends ResourceContainer

class_name ItemContainer

const ITEM_BACKGROUND_COLOR: Color = Color(0, 0, 139, 1)

var ItemBackground: Sprite2D
var ItemSprite: Sprite2D
var FrameOutline: Sprite2D

var isEmpty: bool

func _init(newResource: Item, newConType: ContainerType) -> void:
	#custom_minimum_size = Vector2(39, 60)
	#size = Vector2(39, 60)
	#self_modulate = Color.TRANSPARENT
	container_type = newConType
	resource_type = ResourceType.ITEM
	resource = newResource
	
	isEmpty = newResource == null
	
	assert(container_type != ContainerType.PLAYER_TILE, "Items cannot be used inside the Player Object!")
	assert(container_type == ContainerType.GAMEBAR || !isEmpty, "Only the GameBar can have empty Item Containers!")
	
	ItemBackground = Sprite2D.new()
	ItemBackground.texture = CanvasTexture.new()
	ItemBackground.region_enabled = true
	ItemBackground.region_rect = Rect2(Vector2(0, 0), BASE_RESOURCE_SIZE)
	ItemBackground.position = BASE_RESOURCE_SIZE/2 #Vector2(37.5, 52.5)
	ItemBackground.self_modulate = ITEM_BACKGROUND_COLOR
	ItemBackground.name = "ItemBackground"
	add_child(ItemBackground)
	
	ItemSprite = Sprite2D.new()
	ItemSprite.position = BASE_RESOURCE_SIZE/2 #Vector2(37.5, 52.5)
	ItemSprite.scale = Vector2(0.5, 0.5)
	ItemSprite.name = "ItemSprite"
	add_child(ItemSprite)
	
	FrameOutline = Sprite2D.new()
	FrameOutline.texture = CanvasTexture.new()
	FrameOutline.region_enabled = true
	FrameOutline.region_rect = Rect2(Vector2(0, 0), BASE_RESOURCE_SIZE)
	FrameOutline.position = BASE_RESOURCE_SIZE/2#Vector2(37.5, 52.5)
	FrameOutline.material = ShaderMaterial.new()#-------------------------------------------------
	FrameOutline.material.shader = load("res://shaders/DashedOutline.gdshader")
	FrameOutline.name = "Outline"
	add_child(FrameOutline)
	
	if(isEmpty):
		ItemSprite.visible = false
		FrameOutline.visible = false
	else:
		ItemSprite.texture = resource.getImage()
		if(container_type == ContainerType.GAMEBAR && resource.passive):
			FrameOutline.visible = false
	
	super()

func REgenerateResource(newResource: Resource = null, become_empty: bool = false, consumablesOnly: bool = false) -> void:#-------------------------------------------------------
	var newItem: Item
	
	assert(!become_empty || container_type == ContainerType.GAMEBAR)
	
	if(newResource != null):
		newItem = newResource
	elif(!become_empty):
		newItem = Item.getRandomItem(GameScene.Game, container_type == ContainerType.SHOP, consumablesOnly)
	
	resource = newItem
	if(newItem != null):
		isEmpty = false
		ItemSprite.visible = true
		ItemSprite.texture = newItem.getImage()
		if(container_type == ContainerType.GAMEBAR && newItem.passive):
			FrameOutline.visible = false
		else:
			FrameOutline.visible = true
	else:
		ItemSprite.visible = false
		FrameOutline.visible = false
		isEmpty = true
	
	if(container_type == ContainerType.SHOP):
		price = resource.getShopPrice()
		checkShopAffordability()

func getName(Tip: UITip) -> String:
	if(isEmpty):
		return StringsManager.ItemStrings["Empty Slot"]["NAME"]
	
	return resource.getName()

func getKeywords(Tip: UITip) -> String:
	if(isEmpty):
		return StringsManager.ItemStrings["empty"]
	
	return resource.getKeywords()

func getDescription(Tip: UITip) -> String:
	if(isEmpty):
		return StringsManager.ItemStrings["Empty Slot"]["DESCRIPTION"]
	
	return resource.getDescription()

func DIS_ENable(enable: bool) -> void:
	if(enable):
		FrameOutline.self_modulate = Color.WHITE
	else:
		FrameOutline.self_modulate = Color.RED
	
	isEnabled = enable

func checkShopAffordability() -> void:
	super()
	
	FrameOutline.self_modulate = CostText.self_modulate

func finalPress() -> void:
	if(container_type == ContainerType.SHOP):
		var emptySlotExists: bool = false
		for slot in GameScene.PlayerBar.ItemSlots:
			if(slot.resource == null):
				emptySlotExists = true
				break
		
		if(!emptySlotExists):
			return
	
	super()
	
	if(isEnabled && container_type == ContainerType.SHOP):
		SOLD.visible = true

func _mouse_entered() -> void:
	super()
	
	if(GameScene.GameShop.freebies <= 0 && GameScene.GameShop.currency < price):
		return
	
	if(FrameOutline.visible):
		FrameOutline.set_instance_shader_parameter("speed", 5.0)

func _mouse_exited() -> void:
	super()
	
	if(FrameOutline.visible):
		FrameOutline.set_instance_shader_parameter("speed", 0.0)
