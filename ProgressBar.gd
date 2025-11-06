extends Sprite2D

var progress: float = 1.0
var old_maxScore: int = 0
var maxScore: int = 50
var currentScore: int = 0

var maxScore_list: Array[int] = [50, 150, 350, 1000, 99999]
var maxScore_index: int = 0

#var owner_id: int
var is_updating: bool = false

func _ready() -> void:
	$ScoreControl/Score.text = str(currentScore)
	$MaxScoreControl/MaxScore.text =  str(maxScore_list[0])
	$LevelControl/Level.text = "1"

func _process(_delta: float) -> void:
	if(currentScore >= maxScore):
		old_maxScore = maxScore
		maxScore_index += 1
		$LevelControl/Level.text = str(maxScore_index+1)
		#if(HighLevelNetworkHandler.is_singleplayer || owner_id == multiplayer.get_unique_id()):
		get_parent().Progress()
		Tile_Info.level = maxScore_index
		maxScore = maxScore_list[maxScore_index]
		$ScoreControl/Score.text = str(currentScore)
		$MaxScoreControl/MaxScore.text = str(maxScore)
	
	$ScoreControl/Score.text = str(currentScore)
	$MaxScoreControl/MaxScore.text = str(maxScore)
	progress = (float)(currentScore - old_maxScore)/(maxScore - old_maxScore)
	set_instance_shader_parameter("progress_alpha", 250*progress)

func uodateScore(newScore: int) -> void:
	#if !is_multiplayer_authority(): return
	is_updating = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "currentScore", newScore, 0.5)
	await tween.finished
	is_updating = false
