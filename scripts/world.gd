extends Node2D

var bubble_scene = load("res://scenes/bubble.tscn")
var bubble_timer = Timer.new()
var bubble_cooldown = 0.10 # Seconds

func _ready():
	add_child(bubble_timer)
	bubble_timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("add_bubble"):
		if bubble_timer.is_stopped():
			var bubble_instance : CharacterBody2D = bubble_scene.instantiate()
			bubble_instance.position = get_global_mouse_position()
			add_child(bubble_instance)
			
			bubble_timer.start(bubble_cooldown)
