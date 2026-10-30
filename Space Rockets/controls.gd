extends Control

const CAMPAIGN_SCENE = "res://Space Rockets/scenes/Wave 1.tscn"
const ENDLESS_SCENE = "res://Space Rockets/scenes/endless_mode.tscn"

@onready var little_ship: Node2D = get_node_or_null("LittleShip")
@onready var high_score_label: Label = get_node_or_null("HighScore")


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
	GameState.reset()
	get_tree().change_scene_to_file(CAMPAIGN_SCENE)
	
func _on_endless_void_pressed() -> void:
	GameState.reset(true)
	get_tree().change_scene_to_file(ENDLESS_SCENE)
	

func _on_quit_pressed() -> void:
	get_tree().quit()
