extends Node2D


@export var speed = 80

@onready var space1 = $Space1
@onready var space2 = $Space2

var height = 0.0
var start_y = 0.0

func _ready():
	height = space1.texture.get_height() * space1.scale.y
	start_y = space1.position.y
	
	space2.flip_v = true
	space2.position = Vector2(space1.position.x, start_y - height)
	
	
func _process(delta):
	
	space1.position.y += speed * delta
	space2.position.y += speed * delta
	
	if space1.position.y >= start_y + height:
		space1.position.y += space2.position.y - height
	if space2.position.y >= start_y + height:
		space2.position.y += space1.position.y - height
