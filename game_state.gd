extends Node

const ART = "res://Resources/Sprites Art By Hannan/"
const BG = "res://Resources/Backgrounds by some websites/"
const LASERS = "res://Resources/Lasers By Ichio.store/"
const SCENES = "res://Space Rockets/scenes/"
const SMALL_SHIP = "res://Resources/Sprites Art By Hannan/player_1_Small.png"

var wave = 0 
var score = 0

var ships = [
	{"name": "Small",   "sprite": SMALL_SHIP,                  "scale": 0.4,  "guns": [0]},
	{"name": "Medium",  "sprite": ART + "player_2_Medium.png",  "scale": 0.42, "guns": [-12, 12]},
	{"name": "Biggest", "sprite": ART + "player 3 Biggest.png", "scale": 0.37, "guns": [-25, 0, 25]},
]

var enemy_types = {
	"basic": {
		"sprite": ART + "1st_Enemy.png", "scale": 0.23, "flip_v": true,
		"hp": 1, "speed": 100, "sway": 0, "points": 10,
		"laser": LASERS + "Enemy 1.png", "laser_scale": 0.55, "laser_speed": 280,
		"aim": false, "fire_min": 2.0, "fire_max": 3.5,
	},
	"second": {
		"sprite": ART + "2nd_Enemy.png", "scale": 0.5, "flip_v": true,
		"hp": 2, "speed": 120, "sway": 60, "points": 20,
		"laser": LASERS + "Enemy 2.png", "laser_scale": 0.55, "laser_speed": 320,
		"aim": true, "fire_min": 1.8, "fire_max": 3.0,
	},
}

var bosses ={
	"boss1": SCENES + "boss_1.tscn",
	"boss2": SCENES + "boss_2.tscn",
	"boss3": SCENES + "boss_3.tscn",
}

var waves = [
	{
		"background": BG + "Space_1.jpg", "ship": 0,
		"one_at_a_time": true,
		"groups": [
			{"type": "basic", "count": 5, "gap": 1.0, "pause": 0.0},
		],
		"hp_bonus": 0, "speed_bonus": 0, "fire_rate": 1.0,
		"boss": "",
	},
	{
		"background": BG + "Space_2.jpg", "ship": 0,
		"one_at_a_time": false,
		"groups": [
			{"type": "basic",  "count": 4, "gap": 1.2, "pause": 2.5},
			{"type": "basic",  "count": 3, "gap": 1.0, "pause": 2.5},
			{"type": "second", "count": 3, "gap": 1.6, "pause": 0.0},
		],
		"hp_bonus": 0, "speed_bonus": 0, "fire_rate": 1.0,
		"boss": "boss1",
	},
	{
		"background": BG + "Space_3.jpg", "ship": 1,
		"one_at_a_time": false,
		"groups": [
			{"type": "basic",  "count": 3, "gap": 1.0, "pause": 2.0},
			{"type": "second", "count": 3, "gap": 1.3, "pause": 2.0},
			{"type": "basic",  "count": 3, "gap": 1.0, "pause": 2.0},
			{"type": "second", "count": 3, "gap": 1.3, "pause": 0.0},
		],
		"hp_bonus": 0, "speed_bonus": 10, "fire_rate": 1.25,
		"boss": "boss2",
	},
	{
		"background": BG + "Space_4.jpg", "ship": 2,
		"one_at_a_time": false,
		"groups": [
			{"type": "basic",  "count": 5, "gap": 0.9, "pause": 2.0},
			{"type": "second", "count": 5, "gap": 1.1, "pause": 2.0},
			{"type": "basic",  "count": 4, "gap": 0.8, "pause": 2.0},
			{"type": "second", "count": 4, "gap": 1.0, "pause": 0.0},
		],
		"hp_bonus": 1, "speed_bonus": 25, "fire_rate": 1.5,
		"boss": "boss3",
	},
]


func current_wave():
	return waves[wave]
	
	
func current_ship():
	return ships[current_wave().ship]	

func reset():
	wave = 0
	score = 0
	

func fit_hitbox(sprite: Sprite2D, hitbox: CollisionShape2D, shrink := 0.8):
	var image = sprite.texture.get_image()
	if image.is_compressed():
		image.decompress()
	var used = Rect2(image.get_used_rect())
	var tex_size = sprite.texture.get_size()

	var shape = RectangleShape2D.new()
	shape.size = used.size * sprite.scale * shrink

	var center_offset = used.get_center() - tex_size / 2.0
	if sprite.flip_h:
		center_offset.x = -center_offset.x
	if sprite.flip_v:
		center_offset.y = -center_offset.y

	hitbox.shape = shape
	hitbox.position = sprite.position + center_offset * sprite.scale
