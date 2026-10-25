extends Control

@onready var little_ship: Node2D = get_node_or_null("LittleShip")

func _ready() -> void:
	if little_ship == null:
		push_warning("LittleShip node not found! Check the node path in Main Scene.")
		return

	var float_tween = create_tween()
	float_tween.set_loops()

	float_tween.tween_property(
		little_ship,
		"position:y",
		little_ship.position.y - 10.0,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	float_tween.tween_property(
		little_ship,
		"position:y",
		little_ship.position.y,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_play_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://Space Rockets/scenes/Wave 1.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
