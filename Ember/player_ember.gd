extends RigidBody2D

@export var launch_force = 1000.0 # TODO: Maybe make this customizable?
var is_aiming
var has_launched
var can_launch
var world

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true # Keeps us in place until we need physics
	contact_monitor = true # Allows us to monitor for collision
	max_contacts_reported = 10
	is_aiming = false
	has_launched = false
	can_launch = false
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
	if Input.is_action_just_pressed("left_click") and is_aiming and not has_launched and can_launch:
		is_aiming = false
		queue_redraw()
		launch()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle2")

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

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in range(state.get_contact_count()):
		var collider = state.get_contact_collider_object(i)
		if collider is StaticBody2D and not "Wall" in collider.name and collider.visible == true:
			# This applies a force OPPOSITE to the contact point,
			# and we do this because otherwise the player gets stuck OR
			# they won't have as much fun
			var normal = state.get_contact_local_normal(i)
			var force_magnitude = 175
			state.apply_central_impulse(normal * force_magnitude)

func _on_body_entered(body: Node2D):
	if body is StaticBody2D and not "Wall" in body.name:
		world.get_points_and_deflate(body)
		#print("Collided with static body: ", body.name)

func _on_body_exited(body: Node2D):
	if body is StaticBody2D and not "Wall" in body.name:
		pass
		#print("Stopped colliding with static body: ", body.name)

# Apply force into direction pointed
func launch():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized() # Get direction pointed
	
	freeze = false
	apply_impulse(direction * launch_force)
	has_launched = true

func reset(pos_to_go_back_to):
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0)
	set_deferred("freeze", true)
	set_deferred("global_position", pos_to_go_back_to)
	is_aiming = false
	has_launched = false

func setup_world():
	world = get_parent() # Now we can call the functions of our parent

func allow_launch():
	can_launch = true

func disallow_launch():
	can_launch = false
