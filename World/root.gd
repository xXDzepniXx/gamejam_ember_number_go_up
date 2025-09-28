extends Node2D

var game_seed
var starting_pos
var player_lives
var accumulated_points
var required_points
var grid_children
var grid_positions = {}
var grid_collision_radii = {}
var colors

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_pos = $PlayerEmber.global_position
	player_lives = 5
	accumulated_points = 0
	required_points = 0
	game_seed = randi()
	grid_children = $Grid.get_children()
	colors = $ColorsHolder.color_values
	
	# Attach signal handlers to all areas containing an interactable object
	for area in grid_children:
		#area.body_entered.connect(_on_ember_body_entered_grid.bind(area))
		for child in area.get_children():
			if child is CollisionShape2D:
				grid_positions[area.name] = child.global_position # Vector2
				grid_collision_radii[area.name] = child.shape.radius # float
			elif child is Label:
				# Begin with 1, go up from there
				child.text = "1"
				child.add_theme_color_override("font_color", Color(colors[1]))
		#area.area_entered.connect(_on_ember_area_entered)

	# Attach signal to bottom wall to detect when player hits/enters it
	$AreaBottomwall.body_entered.connect(_on_ember_body_entered_bottom_wall.bind($AreaBottomwall))
	$PlayerEmber.setup_world() # Let player use our functions

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for area in grid_children:
		for child in area.get_children():
			if child is AnimatedSprite2D:
				child.play()

func _on_ember_body_entered_bottom_wall(body: Node2D, area: Area2D):
	if body is not StaticBody2D:
		print("Body ", body.name, " entered area ", area.name)
		# Player entered bottom wall area, so check if game over OR if player
		# succeeded to going into the next level
		$PlayerEmber.reset(starting_pos)

func _on_ember_area_entered(area: Area2D):
	print("Area ", area.name, " entered")

func get_points_and_deflate(body: StaticBody2D):
	var label = body.find_child("Label")
	var label_num = int(label.text)
	accumulated_points += label_num
	if label_num != 1: # If >1 then it is still divisible by 2
		label_num /= 2
		label.text = str(label_num)
		label.add_theme_color_override("font_color", Color(colors[label_num]))
	else: # It is 1, which means it has to go
		body.visible = false
		body.collision_layer = 0
