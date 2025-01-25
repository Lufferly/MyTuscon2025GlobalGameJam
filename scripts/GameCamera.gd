extends Camera2D


@export var following_player = false
@export var player_node : CharacterBody2D

func _ready():
	#var scale = ProjectSettings.get_setting("display/window/stretch/scale", 1)
	#zoom = Vector2(scale, scale)
	#zoom = Vector2(3, 3)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if following_player:
		set_position(player_node.get_position())
