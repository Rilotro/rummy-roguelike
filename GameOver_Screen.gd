extends Node2D

func GameOver(stats: Array[int]) -> void:
	for i in range($Stats.get_child_count()):
		$Stats.get_child(i).text += str(stats[i])
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
	tween.parallel().tween_property(self, "global_position", Vector2(576, 324), 1)
	await tween.finished
	#$Restart.disabled = false


func _on_Restart_pressed() -> void:
	get_tree().reload_current_scene()
