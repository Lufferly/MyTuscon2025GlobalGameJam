class_name Bubble extends CharacterBody2D


const SPEED = -300.0

var rand_scale_min : float = 0.7
var rand_scale_max : float = 1.3

func _ready():
	var rand_scale = randf_range(rand_scale_min, rand_scale_max)
	scale = Vector2(rand_scale, rand_scale)


func _physics_process(delta):

	velocity.y = SPEED

	move_and_slide()


func _on_area_2d_area_entered(area):
	if area.get_parent() is Player:
		queue_free()
