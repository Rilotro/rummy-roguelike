@abstract
extends GoodButton

class_name ResourceContainer

const BASE_RESOURCE_SIZE: Vector2 = Vector2(75, 105)
#const PRESS_TIMER_THRESHOLD: float = 0.5

var resource: Resource
var resource_type: ResourceType
var container_type: ContainerType

#const Letters: Array[String] = ["A", "B"]

#var mouse_inside: bool
#var stillPressingInside: bool = false
#var pressingTimer: float = 0
#var hoverTimer: float = 0

enum ResourceType{
	TILE, ITEM, MODIFIER
}

enum ContainerType{
	GAMEBAR, SHOP, PLAYER_TILE, SELECTION
}

var Body: Node2D
var parentEffector
var price: int

var CostText: Label
var SOLD: Label

func _init() -> void:
	#pressed.connect(_press)
	
	ButtonIcon = Sprite2D.new()
	ButtonIcon.visible = false
	ButtonIcon.name = "ButtonIcon"
	add_child(ButtonIcon)
	
	ButtonText = Label.new()
	ButtonText.visible = false
	ButtonText.name = "ButtonText"
	add_child(ButtonText)
	
	
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	custom_minimum_size = BASE_RESOURCE_SIZE
	self_modulate = Color.TRANSPARENT
	#action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	CostText = Label.new()
	#CostText.fit_content = true
	#CostText.scroll_active = false
	CostText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CostText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var textSize_Y: float = CostText.get_theme_font("font").get_string_size("0", HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, -1, 20).y
	CostText.custom_minimum_size = Vector2(BASE_RESOURCE_SIZE.x, textSize_Y)
	#CostText.size = Vector2(39, 23)
	CostText.position = Vector2(0, BASE_RESOURCE_SIZE.y)#+10)
	CostText.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CostText.add_theme_font_size_override("font_size", 20)
	CostText.visible = container_type == ContainerType.SHOP
	CostText.name = "CostText"
	CostText.text = "0"
	add_child(CostText)
	
	#checkShopAffordability()
	
	SOLD = Label.new()
	SOLD.text = StringsManager.UIStrings["SHOP"][2]
	
	var newLabelSettings: LabelSettings = LabelSettings.new()
	newLabelSettings.font_size = 36
	newLabelSettings.font_color = Color.RED
	newLabelSettings.outline_size = 5
	newLabelSettings.outline_color = Color.BLACK
	SOLD.label_settings = newLabelSettings
	
	SOLD.rotation = -PI/4
	
	var newStyleBoxTexture: StyleBoxTexture = StyleBoxTexture.new()
	newStyleBoxTexture.texture = CanvasTexture.new()
	newStyleBoxTexture.texture_margin_left = 5
	newStyleBoxTexture.texture_margin_right = 5
	newStyleBoxTexture.modulate_color = Color.BLACK
	newStyleBoxTexture.modulate_color.a = 150.0/255
	SOLD.add_theme_stylebox_override("normal", newStyleBoxTexture)
	
	var textSize: Vector2 = SOLD.get_theme_font("font").get_string_size("SOLD", SOLD.horizontal_alignment, -1, newLabelSettings.font_size)
	textSize.x += newStyleBoxTexture.texture_margin_left+newStyleBoxTexture.texture_margin_right
	var centerPoint: Vector2 = Vector2(textSize.x/2 * cos(SOLD.rotation) - textSize.y/2 * sin(SOLD.rotation), textSize.y/2 * cos(SOLD.rotation) + textSize.x/2 * sin(SOLD.rotation))
	SOLD.position = -centerPoint + BASE_RESOURCE_SIZE/2
	
	SOLD.visible = false
	SOLD.name = "SOLD"
	add_child(SOLD)
	
	if(container_type == ContainerType.SHOP):
		price = resource.getShopPrice()

func _ready() -> void:
	match container_type:
		ContainerType.GAMEBAR:
			parentEffector = GameScene.PlayerBar
		ContainerType.SHOP:
			parentEffector = GameScene.Game.GameShop
		ContainerType.PLAYER_TILE:
			parentEffector = GameScene.MainPlayer
		ContainerType.SELECTION:
			parentEffector = GameScene.currSelectScreen
	
	if(container_type == ContainerType.SHOP):
		checkShopAffordability()
	
	#Vector2(-55.0, 19.0)
	
	#var testLabel: LabelSettings = LabelSettings.new()
	#testLabel.font_size = 20
	##testLabel.font.get_string_size("0")
	#print()

#func _process(delta: float) -> void:
	#checkHovering(delta)
	#checkButtonAction(delta)

@abstract
func REgenerateResource(newResource: Resource = null) -> void#-----------------------------------------------------------------------------------------------------------------------------------------

func checkShopAffordability() -> void:
	if(container_type != ContainerType.SHOP):
		return
	
	if(GameScene.GameShop.freebies > 0):
		CostText.text = str(0)
		CostText.self_modulate = Color.GOLD
	else:
		CostText.text = str(price)
		if(GameScene.GameShop.currency >= price):
			CostText.self_modulate = Color.WHITE
		else:
			CostText.self_modulate = Color.RED

#func checkHovering(delta: float) -> void:
	#super(delta)

#func checkButtonAction(delta: float) -> void:
	#if(Input.is_action_just_released("Left_Click") && stillPressingInside):
		#if(pressingTimer <= PRESS_TIMER_THRESHOLD):
			#finalPress()
		#else:
			#lateFinalPress()
	#
	#if(Input.is_action_pressed("Left_Click") && stillPressingInside):
		#pressing(delta)
	#
	#if(Input.is_action_just_pressed("Left_Click") && mouse_inside):
		#initialPress()

#func initialPress() -> void:
	#super()
	#
	#

func finalPress() -> void:
	if(container_type == ContainerType.SHOP && GameScene.Game.GameShop.freebies <= 0 && GameScene.Game.GameShop.currency < price):
		return
	
	super()
	
	if(!isEnabled):
		return
	
	parentEffector.containerPressed(self)

#func _mouse_entered() -> void:
	#mouse_inside = true

#func _mouse_exited() -> void:
	#super()
	#
	#
