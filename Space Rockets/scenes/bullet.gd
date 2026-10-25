extends Area2D

@export var speed = 600
var direction = Vector2.UP
var from_player = true


func _ready():
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	
	if not from_player:
		$Sprite2D.modulate = Color(1, 0.3, 0.3)
		$Sprite2D.rotation = PI / 2
		

func _physics_process(delta):
	position += direction * speed * delta
	
		# player bullets only hurt enemies, enemy bullets only hurt the player
		
func _on_hit(other):
	var target = "enemies" if from_player else "player"	
	if other.is_in_group(target):
		other.take_damage(1)
		queue_free()
			
			
func _on_body_entered(body):
	if not from_player and body.is_in_group("players"):
		body.take_damage(1)
		queue_free()
			
