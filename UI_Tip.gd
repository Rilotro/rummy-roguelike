extends Control

class_name UITip

const BASE_TIP_SIZE: Vector2 = Vector2(300, 250)
const BANNER_SIZE_Y: float = 30
const SEPARATOR_SIZE_Y: float = 5
const KEYWORD_SIZE_Y: float = 37.5
const EDGE_SEPARATION: float = 5
const EFFECTS_SIZE_Y: float = BASE_TIP_SIZE.y-BANNER_SIZE_Y-SEPARATOR_SIZE_Y-KEYWORD_SIZE_Y-EDGE_SEPARATION

@export var Body: Sprite2D
@export var newSeparator: Sprite2D
@export var Banner: Sprite2D
@export var Banner_Text: RichTextLabel
@export var Keyword_Text: RichTextLabel
@export var Effects_Text: RichTextLabel

var currContainer: GoodButton
var resizeComplete: bool = false

enum UIType{
	TILE, ITEM, MODIFIER, UI
}

func _init(container: GoodButton) -> void:
	currContainer = container
	
	#custom_minimum_size = BASE_TIP_SIZE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	#size = Vector2(250, 200)
	
	Body = Sprite2D.new()
	Body.texture = CanvasTexture.new()
	Body.region_enabled = true
	Body.region_rect = Rect2(Vector2(0, 0),BASE_TIP_SIZE)
	Body.position = BASE_TIP_SIZE/2
	Body.self_modulate = Color(0, 0, 0.39, 1)
	Body.name = "Body"
	add_child(Body)
	
	newSeparator = Sprite2D.new()
	newSeparator.texture = CanvasTexture.new()
	newSeparator.region_enabled = true
	newSeparator.region_rect = Rect2(0, 0, BASE_TIP_SIZE.x, SEPARATOR_SIZE_Y)
	newSeparator.position = Vector2(BASE_TIP_SIZE.x/2, BANNER_SIZE_Y+KEYWORD_SIZE_Y + SEPARATOR_SIZE_Y/2)
	newSeparator.self_modulate = Color(0, 0, 0, 0.58)
	newSeparator.name = "Separator"
	add_child(newSeparator)
	
	Banner = Sprite2D.new()
	Banner.texture = CanvasTexture.new()
	Banner.region_enabled = true
	Banner.region_rect = Rect2(0, 0, BASE_TIP_SIZE.x, BANNER_SIZE_Y)
	Banner.position = Banner.region_rect.size/2
	Banner.material = ShaderMaterial.new()
	Banner.material.shader = load("res://UI_Banner.gdshader")
	Banner.name = "Banner"
	add_child(Banner)
	
	Banner_Text = RichTextLabel.new()
	Banner_Text.bbcode_enabled = true
	Banner_Text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Banner_Text.custom_minimum_size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, BANNER_SIZE_Y)
	Banner_Text.size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, BANNER_SIZE_Y)
	Banner_Text.position = Vector2(EDGE_SEPARATION, 0)
	Banner_Text.name = "Banner_Text"
	add_child(Banner_Text)
	
	Keyword_Text = RichTextLabel.new()
	Keyword_Text.bbcode_enabled = true
	Keyword_Text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	Keyword_Text.custom_minimum_size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, KEYWORD_SIZE_Y)
	Keyword_Text.size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, KEYWORD_SIZE_Y)
	Keyword_Text.position = Vector2(EDGE_SEPARATION, BANNER_SIZE_Y)
	Keyword_Text.add_theme_font_size_override("normal_font_size", 12)
	Keyword_Text.add_theme_font_size_override("bold_font_size", 12)
	Keyword_Text.add_theme_font_size_override("bold_italics_font_size", 12)
	Keyword_Text.add_theme_font_size_override("italics_font_size", 12)
	Keyword_Text.add_theme_font_size_override("mono_font_size", 12)
	Keyword_Text.name = "Keyword_Text"
	add_child(Keyword_Text)
	
	Effects_Text = RichTextLabel.new()
	Effects_Text.bbcode_enabled = true
	Effects_Text.fit_content = true
	Effects_Text.scroll_active = false
	Effects_Text.custom_minimum_size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, 0)#EFFECTS_SIZE_Y
	Effects_Text.size = Vector2(BASE_TIP_SIZE.x-EDGE_SEPARATION, 0)
	Effects_Text.position = Vector2(EDGE_SEPARATION, BANNER_SIZE_Y+KEYWORD_SIZE_Y+SEPARATOR_SIZE_Y+EDGE_SEPARATION)#-----------------------------------------------------------------------------------------------------------------
	#Effects_Text.add_theme_constant_override("line_separation", -5)
	Effects_Text.name = "Effects_Text"
	add_child(Effects_Text)
	
	Banner_Text.text = container.getName(self)
	
	Keyword_Text.text = container.getKeywords(self)
	
	Effects_Text.text = container.getDescription(self)
	
	z_index = 3
	
	REsize()

func REsize() -> void:
	global_position = currContainer.global_position + currContainer.getSize()# - Vector2(-30, size.y/2)
	var windowSize: Vector2 = currContainer.get_viewport_rect().size
	#Effects_Text.get_theme_font("font").get_string_size(Effects_Text.text, Effects_Text.horizontal_alignment, )
	#DiscardButton.ButtonText.get_theme_font("font").get_string_size(StringsManager.UIStrings["TURN"]["TEXT"][2]).x
	#while(Effects_Text.size.y > EFFECTS_SIZE_Y):
		#custom_minimum_size.x += 1
		#Effects_Text.custom_minimum_size.x += 1.0
		#Effects_Text.size.x += 1
		#
		#Body.region_rect.size.x += 1
		#newSeparator.region_rect.size.x += 1
		#Banner.region_rect.size.x += 1
		#
		#Body.global_position.x += 0.5
		#newSeparator.global_position.x += 0.5
		#Banner.global_position.x += 0.5
		#
		#Effects_Text.size.y = 122.5
		#await currContainer.get_tree().create_timer(0.0001).timeout
	
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var keywordText_withoutTags = regex.sub(Keyword_Text.text, "", true)
	
	var keywordsSize: Vector2 = Keyword_Text.get_theme_font("font").get_string_size(keywordText_withoutTags, Keyword_Text.horizontal_alignment, -1, Keyword_Text.get_theme_font_size("normal_font_size"))
	var keywordsSize_X: float = keywordsSize.x+10
	
	size.x = BASE_TIP_SIZE.x
	if(keywordsSize_X > Keyword_Text.size.x):
		Keyword_Text.size.x = keywordsSize_X
		size.x = keywordsSize_X+EDGE_SEPARATION
		
		newSeparator.region_rect = Rect2(0, 0, size.x, SEPARATOR_SIZE_Y)
		newSeparator.position = Vector2(size.x/2, BANNER_SIZE_Y+KEYWORD_SIZE_Y + SEPARATOR_SIZE_Y/2)
		
		Banner.region_rect = Rect2(0, 0, size.x, BANNER_SIZE_Y)
		Banner.position = Banner.region_rect.size/2
		
		Banner_Text.size.x = keywordsSize_X
		Effects_Text.size.x = keywordsSize_X
	
	await currContainer.get_tree().create_timer(0.0001).timeout
	
	var TipSize_Y: float = BANNER_SIZE_Y + KEYWORD_SIZE_Y + SEPARATOR_SIZE_Y + 3*EDGE_SEPARATION + Effects_Text.size.y
	#Effects_Text.parse_bbcode()
	size.y = TipSize_Y#Vector2(BASE_TIP_SIZE.x, TipSize_Y)
	Body.region_rect = Rect2(Vector2(0, 0), size)
	Body.position = size/2
	
	var cameraPos = GameScene.MainPlayer.Camera.global_position
	var limits_X: Vector2 = Vector2(cameraPos.x+windowSize.x/2, cameraPos.x-windowSize.x/2)
	var limits_Y: Vector2 = Vector2(cameraPos.y+windowSize.y/2, cameraPos.y-windowSize.y/2)
	
	if(global_position.x > limits_X.x - size.x):
		global_position.x = limits_X.x - size.x - 10
	if(global_position.x < limits_X.y):
		global_position.x = limits_X.y + 10
	
	if(global_position.y > limits_Y.x - size.y):
		global_position.y = limits_Y.x - size.y - 10
	if(global_position.y < limits_Y.y):
		global_position.y = limits_Y.y + 10
	
	resizeComplete = true
