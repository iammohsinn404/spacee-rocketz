extends Node2D

var max_health = 3
var health = 3


func set_health(new_health):
	health = new_health
	queue_redraw()
	
	
func _draw():
	for i in range(max_health):
		var x = i * 50
		var color = Color(0.637, 0.102, 0.0, 1.0)
		if i >= health:
			color = Color(0.312, 0.047, 0.126, 1.0)

		draw_circle(Vector2(x + 10, 10), 10, color)
		draw_circle(Vector2(x + 30, 10), 10, color)
		var points = PackedVector2Array([Vector2(x + 1, 14), Vector2(x + 39, 14), Vector2(x + 20, 38)])
		draw_colored_polygon(points, color)
