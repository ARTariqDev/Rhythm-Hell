extends Node2D

const CELL_SIZE = 64
const WALL = 1
const PATH = 0

var maze_width: int = 15
var maze_height: int = 15
var maze_data = []
var chest_positions = []
var exit_position = Vector2i.ZERO

@export var wall_tile_scene: PackedScene
@export var floor_tile_scene: PackedScene

func generate_maze(level: int):
	# Increase maze size with level
	maze_width = 15 + (level * 2)
	maze_height = 15 + (level * 2)
	
	# Initialize maze with walls
	maze_data = []
	for y in range(maze_height):
		var row = []
		for x in range(maze_width):
			row.append(WALL)
		maze_data.append(row)
	
	# Generate maze using recursive backtracking
	var start = Vector2i(1, 1)
	recursive_backtrack(start)
	
	# Place chests
	place_chests(level + 2)  # More chests each level
	
	# Set exit position
	exit_position = Vector2i(maze_width - 2, maze_height - 2)
	
	# Render the maze
	render_maze()

func recursive_backtrack(pos: Vector2i):
	maze_data[pos.y][pos.x] = PATH
	
	var directions = [
		Vector2i(0, -2), Vector2i(2, 0),
		Vector2i(0, 2), Vector2i(-2, 0)
	]
	directions.shuffle()
	
	for dir in directions:
		var next_pos = pos + dir
		
		if is_valid_cell(next_pos) and maze_data[next_pos.y][next_pos.x] == WALL:
			# Carve path between cells
			var wall_pos = pos + dir / 2
			maze_data[wall_pos.y][wall_pos.x] = PATH
			recursive_backtrack(next_pos)

func is_valid_cell(pos: Vector2i) -> bool:
	return pos.x > 0 and pos.x < maze_width - 1 and pos.y > 0 and pos.y < maze_height - 1

func place_chests(count: int):
	chest_positions.clear()
	var attempts = 0
	var max_attempts = 1000
	
	while chest_positions.size() < count and attempts < max_attempts:
		var x = randi() % (maze_width - 2) + 1
		var y = randi() % (maze_height - 2) + 1
		var pos = Vector2i(x, y)
		
		if maze_data[y][x] == PATH and pos != Vector2i(1, 1):  # Not at start
			if not chest_positions.has(pos):
				chest_positions.append(pos)
		
		attempts += 1

func render_maze():
	# Clear existing tiles
	for child in get_children():
		child.queue_free()
	
	# Create tilemap or individual sprites
	for y in range(maze_height):
		for x in range(maze_width):
			var pos = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			
			if maze_data[y][x] == WALL:
				create_wall(pos)
			else:
				create_floor(pos)

func create_wall(pos: Vector2):
	var wall = StaticBody2D.new()
	wall.position = pos + Vector2(CELL_SIZE/2.0, CELL_SIZE/2.0)
	
	# Visual representation
	var rect = ColorRect.new()
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(-CELL_SIZE/2.0, -CELL_SIZE/2.0)
	rect.color = Color(0.2, 0.2, 0.3)
	wall.add_child(rect)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(CELL_SIZE, CELL_SIZE)
	collision.shape = shape
	wall.add_child(collision)
	
	add_child(wall)

func create_floor(pos: Vector2):
	var floor_rect = ColorRect.new()
	floor_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	floor_rect.position = pos
	floor_rect.color = Color(0.6, 0.6, 0.7)
	add_child(floor_rect)

func get_world_position(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * CELL_SIZE + CELL_SIZE / 2.0, grid_pos.y * CELL_SIZE + CELL_SIZE / 2.0)

func get_grid_position(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / CELL_SIZE), int(world_pos.y / CELL_SIZE))

func is_walkable(grid_pos: Vector2i) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= maze_width or grid_pos.y < 0 or grid_pos.y >= maze_height:
		return false
	return maze_data[grid_pos.y][grid_pos.x] == PATH

# A* pathfinding for monster
func find_path(start_world: Vector2, end_world: Vector2) -> Array:
	var start_grid = get_grid_position(start_world)
	var end_grid = get_grid_position(end_world)
	
	if not is_walkable(start_grid) or not is_walkable(end_grid):
		return []
	
	var open_set = [start_grid]
	var came_from = {}
	var g_score = {start_grid: 0}
	var f_score = {start_grid: heuristic(start_grid, end_grid)}
	
	while open_set.size() > 0:
		# Get node with lowest f_score
		var current = open_set[0]
		var lowest_f = f_score.get(current, INF)
		for node in open_set:
			var f = f_score.get(node, INF)
			if f < lowest_f:
				current = node
				lowest_f = f
		
		if current == end_grid:
			return reconstruct_path(came_from, current)
		
		open_set.erase(current)
		
		# Check neighbors
		var neighbors = [
			current + Vector2i(1, 0),
			current + Vector2i(-1, 0),
			current + Vector2i(0, 1),
			current + Vector2i(0, -1)
		]
		
		for neighbor in neighbors:
			if not is_walkable(neighbor):
				continue
			
			var tentative_g = g_score.get(current, INF) + 1
			
			if tentative_g < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, end_grid)
				
				if not open_set.has(neighbor):
					open_set.append(neighbor)
	
	return []  # No path found

func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path = [get_world_position(current)]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(get_world_position(current))
	return path
