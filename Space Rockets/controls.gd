extends Control

@onready var little_ship = $LittleShip


func _ready() -> void:
	# The little ship floats up and down next to the Play button.
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(little_ship, "position:y", little_ship.position.y - 10.0, 1.2).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(little_ship, "position:y", little_ship.position.y, 1.2).set_trans(Tween.TRANS_SINE)


func _on_play_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://Space Rockets/scenes/Wave 1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
