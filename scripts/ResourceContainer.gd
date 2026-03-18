@abstract
extends Button

class_name ResourceContainer

const TIP_TIMER_TRIGGER: float = 1
const PRESS_TIMER_THRESHOLD: float = 0.5

var resource: Resource
var resource_type: ResourceType
var container_type: ContainerType

var mouse_inside: bool

enum ResourceType{
	TILE, ITEM, MODIFIER
}

enum ContainerType{
	GAMEBAR, SHOP, PLAYER_TILE, SELECTION
}

var Body: Node2D
var parentEffector
var price: int

var CostText: RichTextLabel
var SOLD: RichTextLabel

func _init() -> void:
	#pressed.connect(_press)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	
	custom_minimum_size = Vector2(75, 105)
	self_modulate = Color.TRANSPARENT
	action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	
	CostText = RichTextLabel.new()
	CostText.fit_content = true
	CostText.scroll_active = false
	CostText.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CostText.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	CostText.custom_minimum_size = Vector2(75, 23)
	#CostText.size = Vector2(39, 23)
	CostText.position = Vector2(0, 105)
	CostText.mouse_filter = Control.MOUSE_FILTER_IGNORE
	CostText.add_theme_font_size_override("normal_font_size", 20)
	CostText.visible = container_type == ContainerType.SHOP
	CostText.name = "CostText"
	add_child(CostText)
	
	checkShopAffordability()
	
	SOLD = RichTextLabel.new()
	SOLD.fit_content = true
	SOLD.scroll_active = false
	SOLD.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SOLD.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	SOLD.custom_minimum_size = Vector2(60, 23)
	SOLD.size = Vector2(60, 23)
	SOLD.position = Vector2(-12, 40)
	SOLD.rotation = -45
	SOLD.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SOLD.add_theme_color_override("default_color", Color(1, 0, 0, 1))
	SOLD.add_theme_font_size_override("normal_font_size", 20)
	var newStyleBoxTexture: StyleBoxTexture = StyleBoxTexture.new()
	newStyleBoxTexture.texture = CanvasTexture.new()
	newStyleBoxTexture.modulate_color = Color.BLACK
	SOLD.add_theme_stylebox_override("normal", newStyleBoxTexture)
	SOLD.visible = false
	SOLD.self_modulate = Color(1, 1, 1, 0.78)
	SOLD.name = "SOLD"
	add_child(SOLD)
	
	match container_type:
		ContainerType.GAMEBAR:
			parentEffector = GameScene.Game.ItemBar
		ContainerType.SHOP:
			parentEffector = GameScene.Game.GameShop
		ContainerType.PLAYER_TILE:
			parentEffector = GameScene.Game.PB
		ContainerType.SELECTION:
			parentEffector = GameScene.Game.tileSelectScreen

var hoverTimer: float = 0
var Tip: UITip

func _process(delta: float) -> void:
	if(mouse_inside && !stillPressingInside):
		hoverTimer += delta
		if(hoverTimer >= TIP_TIMER_TRIGGER && Tip == null):
			Tip = UITip.new(self)
			Tip.name = "UITip"
			GameScene.Game.add_child(Tip)
	
	checkButtonAction(delta)

@abstract
func REgenerateResource(newResource: Resource = null) -> void#---------------------------------------------------------------------------------

func getSize() -> Vector2:
	return size

func checkShopAffordability() -> void:
	if(container_type != ContainerType.SHOP):
		return
	
	if(GameScene.Game.GameShop.freebies > 0):
		CostText.text = str(0)
		CostText.self_modulate = Color.GOLD
	else:
		CostText.text = str(price)
		if(GameScene.Game.GameShop.currency >= price):
			CostText.self_modulate = Color.WHITE
		else:
			CostText.self_modulate = Color.RED

var stillPressingInside: bool = false
#var hasPassed_PressTimerThreshold: bool = false
var pressingTimer: float = 0

func checkButtonAction(delta: float) -> void:
	if(Input.is_action_just_released("Left_Click") && stillPressingInside):
		if(pressingTimer <= PRESS_TIMER_THRESHOLD):
			finalPress()
		else:
			lateFinalPress()
	
	if(Input.is_action_pressed("Left_Click") && stillPressingInside):
		pressing(delta)
	
	if(Input.is_action_just_pressed("Left_Click") && mouse_inside):
		initialPress()

func initialPress() -> void:
	stillPressingInside = true
	#hasPassed_PressTimerThreshold = false
	hoverTimer = 0
	pressingTimer = 0

func pressing(delta: float) -> void:
	pressingTimer += delta

func finalPress() -> void:
	if(container_type == ContainerType.SHOP && GameScene.Game.GameShop.freebies <= 0 && GameScene.Game.GameShop.currency < price):
		return
		
	parentEffector.containerPressed(self)

func lateFinalPress() -> void:
	pass

func _mouse_entered() -> void:
	mouse_inside = true

func _mouse_exited() -> void:
	mouse_inside = false
	stillPressingInside = false
	
	hoverTimer = 0
	if(Tip != null):
		Tip.queue_free()
