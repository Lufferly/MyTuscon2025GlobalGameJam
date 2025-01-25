extends Camera2D


@export var following_player = false
@export var player_node : CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if following_player:
		set_position(player_node.get_position())
