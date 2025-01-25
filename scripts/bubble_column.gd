extends StaticBody2D

var bubble_scene = load("res://scenes/bubble.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Create a bubble after the timer runs out, the timer will automatically start itself again
func _on_bubble_timer_timeout():
	var bubble_instance : CharacterBody2D = bubble_scene.instantiate()
	add_child(bubble_instance)
	bubble_instance.position = Vector2.ZERO
