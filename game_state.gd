extends Node

const ART = "res://Resources/Sprites Art By Hannan/"
const BG = "res://Resources/Backgrounds by some websites/"
const SMALL_SHIP = "res://Resources/Sprites Art By Hannan/player_1_Small.png"

var wave = 0 
var score = 0

var ships = [
	{"name": "Small",   "sprite": SMALL_SHIP,                  "scale": 0.4,  "guns": [0]},
	{"name": "Medium",  "sprite": ART + "player_2_Medium.png",  "scale": 0.42, "guns": [-12, 12]},
	{"name": "Biggest", "sprite": ART + "player 3 Biggest.png", "scale": 0.37, "guns": [-25, 0, 25]},
]

var waves = [
	{"count": 5, "speed": 100, "gap": 2.0, "hp": 1,  "shoot": true, "sway": 0,   "points": 10,  "ship": 0, "scale": 0.23, "sprite": ART + "1st_Enemy.png"},
	{"count": 8, "speed": 130, "gap": 1.6, "hp": 1,  "shoot": true, "sway": 0,   "points": 15,  "ship": 1, "scale": 0.5,  "sprite": ART + "2nd_Enemy.png"},
	{"count": 6, "speed": 150, "gap": 1.5, "hp": 2,  "shoot": true, "sway": 60,  "points": 25,  "ship": 1, "scale": 0.65, "sprite": ART + "3rd_Boss_Enemy.png"},
	{"count": 1, "speed": 40,  "gap": 1.0, "hp": 12, "shoot": true, "sway": 120, "points": 200, "ship": 2, "scale": 0.45, "sprite": ART + "1st_Boss_Enemy.png"},
]


func current_wave():
	return waves[wave]
	
	
func current_ship():
	return ships[current_wave().ship]	

func reset():
	wave = 0
	score = 0
	

func fit_hitbox(sprite: Sprite2D, hitbox: CollisionShape2D, shrink := 0.8):
	var tex_size = sprite.texture.get_size()
	var used = Rect2(sprite.texture.get_image().get_used_rect())
	var shape = RectangleShape2D.new()
	shape.size = used.size * sprite.scale * shrink
	hitbox.shape = shape
	hitbox.position = sprite.position + (used.get_center() - tex_size / 2.0) * sprite
