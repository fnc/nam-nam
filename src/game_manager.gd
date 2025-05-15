extends Node

# Grid reference
@onready var grid_manager = $"../gameArea"

# Game properties
var grid_size: Vector2
var cell_size: Vector2
var board = []  # Stores cell occupancy (2D array)
var Block_scene = preload("res://block.tscn")  # Replace with actual Block scene

# Called when the scene loads
func _ready():
	grid_size = grid_manager.get_grid_dimensions()
	cell_size = grid_manager.get_cell_size()
	
	# Initialize empty board
	board.resize(int(grid_size.x))
	for x in range(int(grid_size.x)):
		board[x] = []
		board[x].resize(int(grid_size.y))
		board[x].fill(null)  # Empty cells
	
	# Spawn first piece
	spawn_Block_pair()

func _process(_delta):
	apply_gravity()


# Function to spawn new Blocks at the top center of the grid
func spawn_Block_pair():
	var center_x = int(grid_size.x / 2)
	var start_positions = [Vector2(center_x, int(grid_size.y)), Vector2(center_x, int(grid_size.y) - 1)]  # Two Blocks
	var cell_size = grid_manager.get_cell_size()
	
	for pos in start_positions:
		var Block = Block_scene.instantiate()
		Block.position = grid_manager.get_cell_center(pos.x, pos.y)
		Block.grid_pos = pos
		Block.set_random_type()
		
		# Scale Block to fit the cell size
		var texture_size = Block.get_node("Sprite2D").texture.get_size()
		Block.scale = Vector2(cell_size.x / texture_size.x, cell_size.y / texture_size.y)


		add_child(Block)
		board[pos.x-1][pos.y-1] = Block  # Mark the grid as occupied

func apply_gravity():
	for x in range(int(grid_size.x)):  # Loop through each column
		for y in range(int(grid_size.y) - 2, -1, -1):  # Start from second-to-last row, moving up
			if board[x][y] != null:  # If Puyo exists here
				var target_y = y + 1
				while target_y > grid_size.y and board[x][target_y] == null:  # Ensure valid row and empty below
					move_Block(Vector2(x, target_y - 1), Vector2(x, target_y))
					target_y += 1  # Keep moving down until blocked


# Moves a Block from one grid cell to another
func move_Block(from_pos: Vector2, to_pos: Vector2):
	var Block = board[from_pos.x][from_pos.y]
	if Block:
		Block.position = grid_manager.get_cell_center(to_pos.x, to_pos.y)
		Block.grid_pos = to_pos
		
		board[from_pos.x][from_pos.y] = null
		board[to_pos.x][to_pos.y] = Block

# Function to check for matches (connected groups of same color)
func check_for_matches():
	var matches = []
	var checked_cells = {}
	
	for x in range(int(grid_size.x)):
		for y in range(int(grid_size.y)):
			if board[x][y] and not checked_cells.has(Vector2(x, y)):
				var connected = find_connected_Blocks(Vector2(x, y))
				if connected.size() >= 4:
					matches.append_array(connected)
	
	# Remove matched Blocks
	for pos in matches:
		remove_Block(pos)
		apply_gravity() 

# Finds all connected Blocks of the same color
func find_connected_Blocks(start_pos: Vector2):
	var color = board[start_pos.x][start_pos.y].color_type
	var stack = [start_pos]
	var connected = []
	
	while stack:
		var pos = stack.pop_front()
		if pos in connected:
			continue
		
		connected.append(pos)
		
		for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:  # Check adjacent cells
			var neighbor = pos + dir
			if is_valid_position(neighbor) and board[neighbor.x][neighbor.y] and board[neighbor.x][neighbor.y].color_type == color:
				stack.append(neighbor)
	
	return connected

# Remove Block at given grid position
func remove_Block(pos: Vector2):
	if board[pos.x][pos.y]:
		board[pos.x][pos.y].queue_free()
		board[pos.x][pos.y] = null

# Checks if a position is within bounds
func is_valid_position(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y
