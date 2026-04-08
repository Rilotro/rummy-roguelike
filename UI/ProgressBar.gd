extends Sprite2D

class_name ExperienceBar

const MAX_SCORE_LIST: Array[int] = [50, 150, 350, 1000, 99999]#-------------------------------------------------------------------
const BAR_SIZE: Vector2 = Vector2(250, 30)

var currScoreLabel: Label
var maxScoreLabel: Label
var LevelLabel: Label

#var progress: float = 1.0
#var old_maxScore: int = 0
var maxScore: int = 50
@export var currScore: int = 0
var maxScore_index: int = 0

static var level: int = 1

#var owner_id: int
var is_updating: bool = false

func _init() -> void:
	texture = CanvasTexture.new()
	region_enabled = true
	region_rect = Rect2(Vector2(0, 0), BAR_SIZE)
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/ProgressBar.gdshader")
	
	var ScoreSize: Vector2
	
	currScoreLabel = Label.new()
	currScoreLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	currScoreLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ScoreSize = currScoreLabel.get_theme_font("font").get_string_size(str(currScore))
	currScoreLabel.custom_minimum_size = Vector2(ScoreSize.x*1.1, ScoreSize.y)
	currScoreLabel.position = Vector2(-ScoreSize.x*1.1-region_rect.size.x, -ScoreSize.y/2)
	currScoreLabel.text = str(currScore)
	currScoreLabel.name = "currScoreLabel"
	add_child(currScoreLabel)
	
	
	maxScoreLabel = Label.new()
	maxScoreLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	maxScoreLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ScoreSize = maxScoreLabel.get_theme_font("font").get_string_size(str(MAX_SCORE_LIST[0]))
	maxScoreLabel.custom_minimum_size = Vector2(ScoreSize.x*1.1, ScoreSize.y)
	maxScoreLabel.position = Vector2(region_rect.size.x, -ScoreSize.y/2)
	maxScoreLabel.text = str(MAX_SCORE_LIST[0])
	maxScoreLabel.name = "maxScoreLabel"
	add_child(maxScoreLabel)
	
	LevelLabel = Label.new()
	LevelLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	LevelLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ScoreSize = LevelLabel.get_theme_font("font").get_string_size(str(level))
	LevelLabel.custom_minimum_size = Vector2(ScoreSize.x*1.1, ScoreSize.y)
	LevelLabel.position = Vector2(-ScoreSize.x/2, region_rect.size.y/2)
	LevelLabel.text = str(level)
	LevelLabel.name = "LevelLabel"
	add_child(LevelLabel)
	
	set_instance_shader_parameter("progress_alpha", 0)

#func _ready() -> void:
	#$ScoreControl/Score.text = str(currScore)
	#$MaxScoreControl/MaxScore.text =  str(MAX_SCORE_LIST[0])
	#$LevelControl/Level.text = "1"

#func _process(_delta: float) -> void:
	#if(currScore >= maxScore):
		#old_maxScore = maxScore
		#maxScore_index += 1
		#$LevelControl/Level.text = str(maxScore_index+1)
		##if(HighLevelNetworkHandler.is_singleplayer || owner_id == multiplayer.get_unique_id()):
		#get_parent().Progress()
		#Tile.level = maxScore_index
		#maxScore = MAX_SCORE_LIST[maxScore_index]
		#$ScoreControl/Score.text = str(currScore)
		#$MaxScoreControl/MaxScore.text = str(maxScore)
	#
	#$ScoreControl/Score.text = str(currScore)
	#$MaxScoreControl/MaxScore.text = str(maxScore)
	#progress = (float)(currScore - old_maxScore)/(maxScore - old_maxScore)
	#set_instance_shader_parameter("progress_alpha", 250*progress)

#func uodateScore(newScore: int) -> void:
	##if !is_multiplayer_authority(): return
	#is_updating = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(self, "currentScore", newScore, 0.5)
	#await tween.finished
	#is_updating = false

var experienceTween: Tween
var unaddedExperience: int = 0

func gainExperience(addedExperience: int) -> void:
	if(experienceTween != null && !experienceTween.is_running()):
		experienceTween.stop()
	
	unaddedExperience += addedExperience
	lastInterpolation = 0
	experienceTween = create_tween()
	experienceTween.tween_method(updateLabels, 0, unaddedExperience, 1)

var lastInterpolation: int = 0

func updateLabels(interpolatedExperience: int) -> void:
	var interpolatedDelta: int = interpolatedExperience-lastInterpolation
	lastInterpolation = interpolatedExperience
	
	unaddedExperience -= interpolatedDelta
	currScore += interpolatedDelta
	if(currScore >= MAX_SCORE_LIST[level-1]):
		currScore -= MAX_SCORE_LIST[level-1]
		level += 1
	
	currScoreLabel.text = str(currScore)
	maxScoreLabel.text = str(MAX_SCORE_LIST[level-1])
	LevelLabel.text = str(level)
	
	var progress: float = float(currScore)/MAX_SCORE_LIST[level-1]
	set_instance_shader_parameter("progress_alpha", 250*progress)
