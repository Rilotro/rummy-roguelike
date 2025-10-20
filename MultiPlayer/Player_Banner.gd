extends Control

func _on_ready_pressed() -> void:
	$Ready_Check.visible = !$Ready_Check.visible

func is_ready() -> bool:
	return $Ready_Check.visible

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if(is_multiplayer_authority()):
		$PlayerName.text = HighLevelNetworkHandler.username
