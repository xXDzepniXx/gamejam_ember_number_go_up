extends RigidBody2D

@export var launch_force = 1000.0 # TODO: Maybe make this customizable?
var is_aiming
var has_launched

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true # Keeps us in place until we need physics
	contact_monitor = true # Allows us to monitor for collision
	max_contacts_reported = 10
	is_aiming = false
	has_launched = false
	body_entered.connect(_on_body_entered) # Setup signal
	body_exited.connect(_on_body_exited)

# Called when there is an input event. The input event propagates up through the node tree until a node consumes it.
func _input(_event: InputEvent):
	if Input.is_action_pressed("right_click"):
		is_aiming = true
		queue_redraw()
	if Input.is_action_just_released("right_click"):
		is_aiming = false
		queue_redraw()
	if Input.is_action_just_pressed("left_click") and is_aiming and not has_launched:
		is_aiming = false
		queue_redraw()
		launch_ball()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")

# Called when CanvasItem has been requested to redraw (after queue_redraw() is called, either manually or by the engine).
func _draw():
	if not has_launched and is_aiming:
		var mouse_pos = get_local_mouse_position()
		var direction = mouse_pos.normalized()
		var dashed_line_distance = 100
		var arrow_distance = 125
		var dashed_line_tip = direction * dashed_line_distance
		var arrow_tip = direction * arrow_distance
		
		draw_dashed_line(Vector2.ZERO, dashed_line_tip, Color.GRAY, 3.0)
		
		var perpendicular = Vector2(-direction.y, direction.x)
		var base1 = arrow_tip - direction * 20 + perpendicular * 15
		var base2 = arrow_tip - direction * 20 - perpendicular * 15
		
		var arrow_points = PackedVector2Array([arrow_tip, base1, base2])
		draw_colored_polygon(arrow_points, Color.WHITE)

func _on_body_entered(body):
	# TODO: When the player collides with the bottom wall, 
	# go to next round or game over, depending on points gathered
	if body is StaticBody2D:
		print("Collided with static body: ", body.name)

func _on_body_exited(body):
	if body is StaticBody2D:
		print("Stopped colliding with static body: ", body.name)

# Apply force into direction pointed
func launch_ball():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized() # Get direction pointed
	
	freeze = false
	apply_impulse(direction * launch_force)
	has_launched = true
