class_name BubbleProjectile extends CharacterBody2D


const SPEED : float = 1000.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	velocity.x = cos(rotation) * SPEED
	velocity.y = sin(rotation) * SPEED
	
	move_and_slide()
	
	# Look through all of our collisions
	for collision_index in get_slide_collision_count():
		var collision = get_slide_collision(collision_index).get_collider()
		# If we collided with world "geometry" (layer 3) then delete
		if collision.collision_layer & (1 << 2):
			queue_free()
