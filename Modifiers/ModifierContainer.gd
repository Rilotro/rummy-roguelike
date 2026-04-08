extends ResourceContainer

class_name ModifierContainer

var Border: Sprite2D
var Outline: Sprite2D
var ModifierImage: Sprite2D

func _init(newResource: Modifier, newConType: ContainerType) -> void:
	resource = newResource
	resource_type = ResourceType.MODIFIER#-----------------------------------------------------------
	container_type = newConType
	
	assert(container_type == ContainerType.GAMEBAR || container_type == ContainerType.SELECTION)
	
	Border = Sprite2D.new()
	Border.texture = CanvasTexture.new()
	Border.region_enabled = true
	Border.region_rect = Rect2(Vector2(0, 0), BASE_RESOURCE_SIZE+Vector2(10, 10))
	Border.position = BASE_RESOURCE_SIZE/2#Vector2(32.5, 50)
	
	match resource.type:
		Modifier.Type.BOON:
			Border.self_modulate = Color.GOLD
		Modifier.Type.CURSE:
			Border.self_modulate = Color.RED
		Modifier.Type.OTHER:
			Border.self_modulate = Color.GRAY
	
	Border.visible = container_type == ContainerType.GAMEBAR
	Border.name = "Border"
	add_child(Border)
	
	Outline = Sprite2D.new()
	Outline.texture = CanvasTexture.new()
	Outline.region_enabled = true
	Outline.region_rect = Rect2(Vector2(0, 0), BASE_RESOURCE_SIZE+Vector2(2, 2))
	Outline.position = BASE_RESOURCE_SIZE/2
	Outline.self_modulate = Color.BLACK
	Outline.name = "Outline"
	add_child(Outline)
	
	ModifierImage = Sprite2D.new()
	ModifierImage.region_rect = Rect2(Vector2(0, 0), BASE_RESOURCE_SIZE)
	ModifierImage.position = BASE_RESOURCE_SIZE/2
	ModifierImage.texture = resource.image
	ModifierImage.scale = Vector2(0.5, 0.5)
	ModifierImage.name = "ModifierImage"
	add_child(ModifierImage)
	
	super()

func REgenerateResource(newResource: Resource = null) -> void:
	var newModifier: Modifier
	if(newResource != null):
		newModifier = newResource
	else:
		newModifier = Modifier.getRandomModifier(true)
	resource = newModifier
	
	ModifierImage.texture = resource.image
	
	match resource.type:
		Modifier.Type.BOON:
			Border.self_modulate = Color.GOLD
		Modifier.Type.CURSE:
			Border.self_modulate = Color.RED
		Modifier.Type.OTHER:
			Border.self_modulate = Color.GRAY

func getName(Tip: UITip) -> String:
	return resource.getName()

func getKeywords(Tip: UITip) -> String:
	return resource.getKeywords()

func getDescription(Tip: UITip) -> String:
	return resource.getDescription()

func finalPress() -> void:
	if(container_type != ContainerType.SELECTION):
		return
	
	super()

func _mouse_entered() -> void:
	super()
	
	if(container_type == ContainerType.SELECTION):
		Border.visible = true

func _mouse_exited() -> void:
	super()
	
	if(container_type == ContainerType.SELECTION):
		Border.visible = false
