extends Control

const CAMPAIGN_SCENE = "res://Space Rockets/scenes/Wave 1.tscn"
const ENDLESS_SCENE = "res://Space Rockets/scenes/endless_mode.tscn"

@onready var little_ship: Node2D = get_node_or_null("LittleShip")
@onready var high_score_label: Label = get_node_or_null("HighScore")
@onready var is_leaving = false


func _ready() -> void:
	show_high_score()
	float_little_ship()


func show_high_score() -> void:
	if high_score_label == null:
		return
	high_score_label.text = "Infinity Best: %d" % GameState.high_score


func float_little_ship() -> void:
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
	start_game(CAMPAIGN_SCENE, false)


func _on_endless_void_pressed() -> void:
	start_game(ENDLESS_SCENE, true)


func start_game(scene_path: String, endless: bool) -> void:
	if is_leaving:
		return

	is_leaving = true
	GameState.reset(endless)
	get_tree().change_scene_to_file(scene_path)

func _on_quit_pressed() -> void:
	get_tree().quit()
