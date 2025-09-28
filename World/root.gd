extends Node2D

const MAX_PLAYER_LIVES = 4
const NUM_GRID_SPACES = 25

var game_seed
var starting_pos
var player_lives : int
var accumulated_points : int
var required_points : int
var points_adder_per_round : int
var rounds : int
var levels : int
var grid_positions = {}
var grid_collision_radii = {}
var previous_round_saved = {}
var grid_sprites = []
var grid_static_bodies = []
var lives_sprites = []
var lives_static_bodies = []
var colors

var possible_grid_animations = {
	0 : "apple",
	1 : "ballincup",
	2 : "hamburger",
	3 : "paper",
	4 : "spinny",
	5 : "toiletpaper"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_pos = $PlayerEmber.global_position
	player_lives = MAX_PLAYER_LIVES
	accumulated_points = 0
	required_points = 8
	points_adder_per_round = 4
	levels = 1
	rounds = 1
	game_seed = randi()
	colors = $ColorsHolder.color_values
	
	$PointsRequired.text = str(required_points)
	
	for static_body in $Lives.get_children():
		lives_static_bodies.append(static_body)
		for child in static_body.get_children():
			if child is AnimatedSprite2D:
				lives_sprites.append(child)
	
	# Attach signal handlers to all areas containing an interactable object
	for static_body in $Grid.get_children():
		grid_static_bodies.append(static_body)
		for child in static_body.get_children():
			if child is CollisionShape2D:
				grid_positions[static_body.name] = child.global_position # Vector2
				grid_collision_radii[static_body.name] = child.shape.radius # float
			elif child is Label:
				# Begin with 1, go up from there
				change_points_text(child, "1", 1)
			elif child is AnimatedSprite2D:
				grid_sprites.append(child)
	
	await all_grids_go_away()
	await randomify_grid_animations()
	await select_grids_to_display()
	await save_game_prev_state()
	
	# Attach signal to bottom wall to detect when player hits/enters it
	$AreaBottomwall.body_entered.connect(_on_ember_body_entered_bottom_wall.bind($AreaBottomwall))
	$PlayerEmber.setup_world() # Let player use our functions
	$PlayerEmber.allow_launch()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for sprite in grid_sprites:
		sprite.play()
	for sprite in lives_sprites:
		sprite.play()

func _on_ember_body_entered_bottom_wall(body: Node2D, area: Area2D):
	if body is not StaticBody2D:
		print("Body ", body.name, " entered area ", area.name)
		$PlayerEmber.reset(starting_pos)
		if accumulated_points >= required_points:
			# PASSED ROUND, GIVE BACK LIVES TO PLAYER AND LOAD NEW ROUND
			var num_lives_to_give_back = accumulated_points / required_points
			player_lives += num_lives_to_give_back
			if player_lives > 4:
				player_lives = MAX_PLAYER_LIVES
			update_lives()
			
			$PlayerEmber.disallow_launch()
			rounds += 1
			required_points += points_adder_per_round
			points_adder_per_round += ceil(points_adder_per_round * 1.5) + 1
			$PointsRequired.text = str(required_points)
			await reset_accumulated_points()
			await all_grids_go_away()
			await randomify_grid_animations()
			await select_grids_to_display()
			await set_points_of_grids()
			await save_game_prev_state()
		else:
			# DID NOT PASS ROUND, LIVES REMAIN THE SAME, LOAD PREVIOUS STATE
			$LoseAudioStream.play()
			player_lives -= 1
			$PlayerEmber.disallow_launch()
			await reset_accumulated_points()
			await load_game_prev_state()
			update_lives()
	
	if player_lives < 0:
		# GAME OVER, TAKE THIS L AND HOLD IT
		player_lives = MAX_PLAYER_LIVES
		rounds = 1
		update_lives()
		await reset_required_points()
		await all_grids_go_away()
		await reset_grid_points_to_start()
		await randomify_grid_animations()
		await select_grids_to_display()
		await save_game_prev_state()
		player_lives = MAX_PLAYER_LIVES
		
	$PlayerEmber.allow_launch()

func get_points_and_deflate(body: StaticBody2D):
	if body.visible == false: # Ignore static bodies that aren't visible
		return
	
	$FlamesAudioStream.play() # Play burning sound
	var label = body.find_child("Label")
	var boom_anim = body.find_child("BoomAnimation")
	var label_num = int(label.text)
	accumulated_points += label_num # Give the full amount, THEN divide it
	$PointsAccumulated.text = str(accumulated_points)
	
	if label_num > 1: # If >1 then it is still divisible by 2
		label_num /= 2
		label.text = str(label_num)
		label.add_theme_color_override("font_color", Color(colors[label_num]))
	else: # It is <=1, which means it has to go
		boom_anim.play("boom")
		boom_anim.visible = true
		await get_tree().create_timer(0.3).timeout
		boom_anim.visible = false
		body.visible = false
		body.collision_layer = 0

func change_points_text(label: Label, text: String, num: int):
	label.text = text
	label.add_theme_color_override("font_color", Color(colors[num]))

func update_lives():
	# Max lives is 4
	for i in range(4):
		if i > (player_lives - 1):
			lives_static_bodies[i].visible = false
		else:
			lives_static_bodies[i].visible = true

func select_grids_to_display():
	var all_numbers = range(0, 25)
	var random_num = randi_range(10, 17)
	var selected = []
		
	all_numbers.shuffle()
	
	for i in range(random_num):
		selected.append(all_numbers[i])
	
	for i in selected:
		grid_static_bodies[i].visible = true
		grid_static_bodies[i].collision_layer = 1
		grid_static_bodies[i].collision_mask = 1
		$BopAudioStream.play()
		await get_tree().create_timer(0.7).timeout

func all_grids_go_away():
	for static_body in grid_static_bodies:
		var label = static_body.find_child("Label")
		static_body.visible = false
		static_body.collision_layer = 0
		change_points_text(label, "1", 1)

func reset_grid_points_to_start():
	for static_body in grid_static_bodies:
		var label = static_body.find_child("Label")
		change_points_text(label, "1", 1)

func set_points_of_grids():
	for static_body in grid_static_bodies:
		var new_points = 1 << randi_range(1, rounds)
		change_points_text(static_body.find_child("Label"), str(new_points), new_points)

func randomify_grid_animations():
	for sprite : AnimatedSprite2D in grid_sprites:
		var random_animation = randi_range(0, 5)
		sprite.play(possible_grid_animations[random_animation])

func save_game_prev_state():
	for static_body : StaticBody2D in grid_static_bodies:
		var points = static_body.find_child("Label").text
		previous_round_saved[static_body.name] = [static_body.visible, static_body.collision_layer, points]

func load_game_prev_state():
	for static_body : StaticBody2D in grid_static_bodies:
		var label = static_body.find_child("Label")
		var points = int(previous_round_saved[static_body.name][2])
		static_body.visible = previous_round_saved[static_body.name][0]
		static_body.collision_layer = previous_round_saved[static_body.name][1]
		change_points_text(label, previous_round_saved[static_body.name][2], points)

func reset_accumulated_points():
	accumulated_points = 0
	$PointsAccumulated.text = "0"

func reset_required_points():
	required_points = 8
	points_adder_per_round = 4
	$PointsRequired.text = str(required_points)
