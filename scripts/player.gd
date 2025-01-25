class_name Player extends CharacterBody2D

# This player uses a finite state machine
# The possible states the player can be
enum States {IDLE, WALKING, RUNNING}
# Represents the player states in strings, for debugging
var STATES_STRING_REPRESENTATION : Array = ["IDLE", "WALKING", "RUNNING"]
# The players current state
var state : States = States.IDLE

@export var ACCELERATION : float = 500.0
@export var DECELERATION : float = 600.0
@export var MAX_WALK_SPEED : float = 255.0
@export var MAX_RUN_SPEED : float = 500.0
@export var BASE_TURN_RADIUS: float = PI * 3# Turn radius per second

# Whether or not the player is walking
var b_player_pressing_move : bool = false
# The position the player is moving to, only relevant if the player is pressing a move key
var point_to_move_to : Vector2 = Vector2.ZERO
# our current speed, should always be positive or zero
var current_speed : float = 0.0
# our current direction
var current_direction : Vector2 = Vector2(0, 1)

var max_breath = 100
var current_breath = max_breath
var breath_loss_per_second = 10


# Calculate our speed
func calculate_speed(current_speed: float, delta: float, b_player_pressing_move: bool, 
	point_to_move_to: Vector2) -> float:
	var new_speed : float
	
	# First check if we are approaching the point we want to move to
	if position.distance_to(point_to_move_to) <= 10:
		new_speed = 0	# Dont move
	# If the player is walking
	elif state == States.WALKING:
		# If we are over our MAX_WALK_SPEED, decelerate down to our MAX_WALK_SPEED
		if current_speed > MAX_WALK_SPEED:
			new_speed = current_speed - (DECELERATION * delta)
			# Clamp so we dont decelerate too much
			new_speed = clamp(new_speed, MAX_WALK_SPEED, new_speed)
		# Otherwise accelerate up to our max walk speed
		else:
			new_speed = current_speed + (ACCELERATION * delta)
			new_speed = clamp(new_speed, 0, MAX_WALK_SPEED)
	# If the player is running
	elif state == States.RUNNING:
		if current_speed > MAX_RUN_SPEED:
			# decelerate down to our MAX_RUN_SPEED
			new_speed = current_speed - (DECELERATION * delta)
			new_speed = clamp(new_speed, MAX_RUN_SPEED, new_speed)
		else:
			new_speed = current_speed + (ACCELERATION * delta)
			new_speed = clamp(new_speed, 0, MAX_RUN_SPEED)
	else:	# If we are idle, decelerate
		new_speed = current_speed - (DECELERATION * delta)
		new_speed = clamp(new_speed, 0, current_speed)
	
	
	return new_speed
	

# Calculate our direction

func calculate_direction(current_direction: Vector2, current_position: Vector2,
	target_position: Vector2, delta: float) -> Vector2:
	var target_direction: Vector2 = current_position.direction_to(target_position)
	
	# The new direction that we will have
	var new_direction: Vector2
	# The max turn radius this process (tick?)
	var max_BASE_TURN_RADIUS: float = BASE_TURN_RADIUS * delta
	# Apply the turn radius, so that we do not snap to our target direction
	if current_direction.angle_to(target_direction) > max_BASE_TURN_RADIUS:
		new_direction = current_direction.rotated(max_BASE_TURN_RADIUS)
	elif current_direction.angle_to(target_direction) < -max_BASE_TURN_RADIUS:
		new_direction = current_direction.rotated(-max_BASE_TURN_RADIUS)
	else:
		new_direction = target_direction

	return new_direction


# Calculate our velocity
func calculate_velocity(current_pos: Vector2, current_direction: Vector2, current_speed: float, 
	current_velocity: Vector2, target_position: Vector2) -> Vector2:
	
	# We dont need to handle delta here because move_and_slide will handle it for us
	var new_velocity = (current_direction * current_speed)
	
	return new_velocity
	
	
func handle_breath(delta):
	current_breath -= breath_loss_per_second * delta

func _physics_process(delta):

	# Handle movement input
	if Input.is_action_pressed("run"):
		# Change the state
		state = States.RUNNING
	elif Input.is_action_pressed("walk"):
		# Change the state
		state = States.WALKING
	else:
		state = States.IDLE
		
	# Find our target position (the mouse)
	if state == States.WALKING or state == States.RUNNING:
		point_to_move_to = get_global_mouse_position()
		
	# Move to our target position if we can move right now
	current_direction = calculate_direction(current_direction, position, point_to_move_to, delta)
	current_speed = calculate_speed(current_speed, delta, b_player_pressing_move, point_to_move_to)
	velocity = calculate_velocity(position, current_direction, current_speed, velocity, point_to_move_to)
	
	$Sprite2D.rotation = current_direction.angle()
	
	# Handle our breath
	handle_breath(delta)
		
	move_and_slide()


func _on_bubble_area_area_entered(area):
	# Gain breath if we touch a bubble
	if area.get_parent() is Bubble:
		current_breath += 100
