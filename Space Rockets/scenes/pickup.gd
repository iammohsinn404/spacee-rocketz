extends Area2D

signal collected(kind, at)

const FALL_SPEED = 110.0
const BOTTOM_EDGE = 600.0
const  OVERDRIVE_SECONDS = 8.0
const HEART_COLOR = Color(0.95, 0.25, 0.35)
const BOLT_COLOR = Color(0.35, 0.9, 1.0)

var kind = "heart"
var age = 0.0

func _ready():
	collision_layer = 0
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	age += delta
	position.y += FALL_SPEED * delta
		
	if position.y > BOTTOM_EDGE:	
		queue_free()	
		
	queue_redraw()
	
func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
		
	if kind == "heart" and body.has_method("heal"):
		body.heal(1)
	elif kind == "overdrive" and body.has_method("start_overdrive"):
		body.start_overdrive(OVERDRIVE_SECONDS)
		
	collected.emit(kind, global_position)
	queue_free()
	
func _draw():
	var color = HEART_COLOR if kind == "heart" else BOLT_COLOR
	var pulse = 1.0 + 0.12 * sin(age * 6.0)

	# Soft glow and a ring so the pickup is easy to spot.
	draw_circle(Vector2.ZERO, 26.0 * pulse, Color(color.r, color.g, color.b, 0.22))
	draw_arc(Vector2.ZERO, 26.0 * pulse, 0.0, TAU, 32, Color(color.r, color.g, color.b, 0.85), 2.0)

	if kind == "heart":
		draw_heart(color)
	else:
		draw_bolt(color)
		
func draw_heart(color: Color) -> void:
	draw_circle(Vector2(-9, -6), 9, color)
	draw_circle(Vector2(9, -6), 9, color)
	draw_colored_polygon(PackedVector2Array([Vector2(-17, -2), Vector2(17, -2), Vector2(0, 18)]), color)
	
func draw_bolt(color: Color) -> void:
	var bolt = PackedVector2Array([
		Vector2(5, -22), Vector2(-10, 3), Vector2(-1, 3),
		Vector2(-6, 22), Vector2(11, -5), Vector2(2, -5),
	])
	draw_colored_polygon(bolt, color)
	
