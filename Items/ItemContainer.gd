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
	ItemBackground.region_rect = Rect2(0, 0, 75, 105)
	ItemBackground.position = Vector2(37.5, 52.5)
	ItemBackground.self_modulate = ITEM_BACKGROUND_COLOR
	ItemBackground.name = "ItemBackground"
	add_child(ItemBackground)
	
	ItemSprite = Sprite2D.new()
	ItemSprite.position = Vector2(37.5, 52.5)
	ItemSprite.scale = Vector2(0.5, 0.5)
	ItemSprite.name = "ItemSprite"
	add_child(ItemSprite)
	
	FrameOutline = Sprite2D.new()
	FrameOutline.texture = CanvasTexture.new()
	FrameOutline.region_enabled = true
	FrameOutline.region_rect = Rect2(0, 0, 75, 105)
	FrameOutline.position = Vector2(37.5, 52.5)
	FrameOutline.material = ShaderMaterial.new()#-------------------------------------------------
	FrameOutline.material.shader = load("res://shaders/DashedOutline.gdshader")
	FrameOutline.name = "Outline"
	add_child(FrameOutline)
	
	if(isEmpty):
		ItemSprite.visible = false
		FrameOutline.visible = false
	else:
		ItemSprite.texture = resource.item_image
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
		ItemSprite.texture = newItem.item_image
		if(container_type == ContainerType.GAMEBAR && newItem.passive):
			FrameOutline.visible = false
		else:
			FrameOutline.visible = true
	else:
		ItemSprite.visible = false
		FrameOutline.visible = false
		isEmpty = true

func _mouse_entered() -> void:
	super()
	
	if(FrameOutline.visible):
		FrameOutline.set_instance_shader_parameter("speed", 5.0)

func _mouse_exited() -> void:
	super()
	
	if(FrameOutline.visible):
		FrameOutline.set_instance_shader_parameter("speed", 0.0)
