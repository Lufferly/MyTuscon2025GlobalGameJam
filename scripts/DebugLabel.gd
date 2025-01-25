extends Label

@export var player_node : Node2D
func _ready():
	position = Vector2.ZERO

func _process(delta):
	text = ""
	text += "Player state: " + player_node.STATES_STRING_REPRESENTATION[player_node.state] + "\n"
	text += "Player speed: " + str(player_node.current_speed) + "\n"
	text += "Player direction: " + str(player_node.current_direction) + "\n"
	text += "Player breath: " + str(player_node.current_breath) + "\n"
