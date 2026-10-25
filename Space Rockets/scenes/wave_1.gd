extends Node2D

const ENEMY = preload("res://Space Rockets/scenes/enemy.tscn")

var data
var spawned = 0
var killed = 0
var start_score = 0
var finished = false

@onready var score_label = $Score
@onready var wave_label = $Wave
@onready var size_label = $Size
@onready var spawn_timer = $SpawnTIme
@onready var player = $SpaceShipBody2D
@onready var hearts = $Hearts

func _ready():
	data = GameState.current_wave()
	start_score = GameState.score
	
	wave_label.text = "Wave = %d" % (GameState.wave + 1)
	score_label.text = "Score = %d" % GameState.score
	size_label.text = "Size = " + player.ship.name
	
	$Background.set_background(load(GameState.BG + "Space_%d.jpg" % (GameState.wave % 4 + 1)))
	
	player.health_changed.connect(hearts.set_health)
	player.died.connect(_on_player_died)
	
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_timer.start(data.gap)
	
func spawn_enemy():
	var enemy = ENEMY.instantiate()
	enemy.position = Vector2(randf_range( -500, 550), -130)	
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)
	enemy.setup(data)
	spawned += 1
	if spawned >= data.count:
		spawn_timer.stop()
		

func _on_enemy_died():
	killed += 1
	GameState.score += data.points
	score_label.text = "Score = %d" % GameState.score
	if killed >= data.count:
		wave_cleared()
		
		
func wave_cleared():
	if finished:
		return
	finished = true

	if GameState.wave + 1 >= GameState.waves.size():     # that was the last wave
		wave_label.text = "YOU WIN!"
		await get_tree().create_timer(3.0).timeout
		GameState.reset()
		get_tree().change_scene_to_file("res://Space Rockets/scenes/Main Scene.tscn")
	else:
		wave_label.text = "Wave %d Cleared!" % (GameState.wave + 1)
		await get_tree().create_timer(2.0).timeout
		GameState.wave += 1
		get_tree().reload_current_scene()
		
		# IF the Player hearts all Broken then present, Game OVER and start the wave again 
func _on_player_died():
	if finished:
		return
	finished = true
	spawn_timer.stop()
	wave_label.text = "Game Over"
	await get_tree().create_timer(2.0).timeout
	GameState.score = start_score                         # restart this wave
	get_tree().reload_current_scene()
			

		
	
