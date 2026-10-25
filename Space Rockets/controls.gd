extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://Space Rockets/scenes/Wave 1.tscn")



func _on_quit_pressed() -> void:
	get_tree().quit()
