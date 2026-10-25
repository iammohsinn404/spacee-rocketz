extends Node2D

@export var speed = 80

@onready var a = $Space1
@onready var b = $Space2

var height = 0.0
var top_y = 0.0


func _ready():
	 
	b.flip_v = true
	for panel in [a, b]:
		panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	get_viewport().size_changed.connect(_layout)
 
	_layout.call_deferred()


func set_background(tex):
	a.texture = tex
	b.texture = tex
	_layout()


func _layout():
	if a.texture == null:
		return

	var view = get_viewport_rect().size
	var tex_size = a.texture.get_size()
	var s = maxf(view.x / tex_size.x, view.y / tex_size.y)
	a.scale = Vector2.ONE * s
	b.scale = a.scale
	height = tex_size.y * s

	var cam = get_viewport().get_camera_2d()
	var center = cam.get_screen_center_position() if cam else view / 2.0
	a.position = center
	b.position = center - Vector2(0, height)
	top_y = center.y


func _process(delta):
	if a.texture == null:
		return

	a.position.y += speed * delta
	b.position.y += speed * delta

	if a.position.y >= top_y + height:
		a.position.y = b.position.y - height
	if b.position.y >= top_y + height:
		b.position.y = a.position.y - height
