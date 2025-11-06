extends Resource

class_name PlayerData

var player_id: int
var Score: int
var player_Node: Node2D

func _init(new_player_id: int, new_Score: int, new_player_Node: Node2D) -> void:
	player_id = new_player_id
	Score = new_Score
	player_Node = new_player_Node

func updateScore(acc_Score: int) -> void:
	if(Score != acc_Score):
		Score = acc_Score
	if(Score != player_Node.Score):#--------------------------------------------------------------------------------------------
		player_Node.addPoints(Score - player_Node.Score)
