extends Node

# Grid reference
@onready var grid_manager = $"../gameArea"

#gravity
var time_elapsed = 0.0
@export var gravity_interval = 0.5  # Configurable lapse

# Game properties
var grid_size: Vector2
var cell_size: Vector2
var board = []  # Stores cell occupancy (2D array)
var Block_scene = preload("res://block.tscn")  # Replace with actual Block scene

var current_blocks = []

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
	
	#background sprites
	grid_manager.spawn_sprites()
	
	# Spawn first piece
	spawn_Block_pair()

func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		print("Left key was just pressed")
		if can_move(Vector2(-1, 0)):  # Check boundaries before moving
			for block in current_blocks:
				var target_pos = block.grid_pos + Vector2(-1, 0)
				move_Block(block.grid_pos, target_pos)

	elif Input.is_action_just_pressed("ui_right"):
		print("Right key was just pressed")
		if can_move(Vector2(1, 0)):  # Check boundaries before moving
			for block in current_blocks:
				var target_pos = block.grid_pos + Vector2(1, 0)
				move_Block(block.grid_pos, target_pos)

	elif Input.is_action_just_pressed("ui_up"):  # Handle rotation
		print("Rotate key was just pressed")
		if can_rotate():  # Check if rotation is valid
			rotate_blocks()

	time_elapsed += _delta
	if time_elapsed >= gravity_interval:
		apply_gravity()
		time_elapsed = 0.0  # Reset timer
		print("Gravity applied!")

func can_move(offset: Vector2) -> bool:
	for block in current_blocks:
		var target_pos = block.grid_pos + offset
		if not is_position_valid(target_pos):
			return false
	return true

func can_rotate() -> bool:
	# Implement logic to check if rotation is possible
	# Example: Check if all new positions are within bounds
	var new_positions = get_rotated_positions()
	for pos in new_positions:
		if not is_position_valid(pos):
			return false
	return true

func get_rotated_positions() -> Array:
	var rotated_positions = []
	var pivot = current_blocks[0]  # Assuming the first block is the pivot
	
	for block in current_blocks:
		# Calculate relative position from pivot
		var relative_pos = block.grid_pos - pivot.grid_pos
		
		# Apply 90-degree clockwise rotation formula: (x, y) -> (-y, x)
		var rotated_pos = Vector2(-relative_pos.y, relative_pos.x)
		
		# Compute new absolute position
		var target_pos = pivot.grid_pos + rotated_pos
		
		rotated_positions.append(target_pos)

	return rotated_positions


# Function to spawn new Blocks at the top center of the grid
func spawn_Block_pair():
	var center_x = int(grid_size.x / 2)
	var start_positions = [Vector2(center_x, int(grid_size.y)-1), Vector2(center_x, int(grid_size.y) - 2)]  # Two Blocks
	current_blocks.clear()
	for pos in start_positions:
		var Block = Block_scene.instantiate()
		Block.position = grid_manager.get_cell_center(pos.x, pos.y)
		Block.grid_pos = pos
		Block.set_random_type()
		
		# Scale Block to fit the cell size
		var texture_size = Block.get_node("Sprite2D").texture.get_size()
		Block.scale = Vector2(- cell_size.x / texture_size.x,- cell_size.y / texture_size.y)
		
		current_blocks.append(Block)
		add_child(Block)
		board[pos.x][pos.y] = Block  # Mark the grid as occupied

func apply_gravity():
	var block_moved = false
	var new_pair_needed = false
	for x in range(int(grid_size.x)):  # Loop through each column
		for y in range(int(grid_size.y)):  # Start from second-to-last row, moving up
			if board[x][y] != null:  # If Puyo exists here
				var target_y = y - 1
				if target_y >= 0 and board[x][target_y] == null:  # Ensure valid row and empty below
					move_Block(Vector2(x, target_y + 1), Vector2(x, target_y))
					block_moved = true
					#target_y += 1  # Keep moving down until blocked
	if !block_moved:
		if !check_for_matches():
			spawn_Block_pair()



# Moves a Block from one grid cell to another
func move_Block(from_pos: Vector2, to_pos: Vector2):
	var Block = board[from_pos.x][from_pos.y]
	if Block:
		Block.position = grid_manager.get_cell_center(to_pos.x, to_pos.y)
		Block.grid_pos = to_pos
		
		board[from_pos.x][from_pos.y] = null
		board[to_pos.x][to_pos.y] = Block

# Function to check for matches (connected groups of same color). Returns true if matches existed
func check_for_matches() -> bool:
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
		#apply_gravity()
	
	if matches.size() > 0:
		return true
	return false

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
			if is_position_valid(neighbor) and board[neighbor.x][neighbor.y] and board[neighbor.x][neighbor.y].color_type == color:
				stack.append(neighbor)
	
	return connected

# Remove Block at given grid position
func remove_Block(pos: Vector2):
	if board[pos.x][pos.y]:
		board[pos.x][pos.y].queue_free()
		board[pos.x][pos.y] = null

# Checks if a position is within bounds
func is_position_valid(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y and not is_occupied(pos)
	
func is_occupied(pos: Vector2) -> bool:
	# Ensure position is within the board bounds

	# Ignore current blocks that are being rotated
	for block in current_blocks:
		if block.grid_pos == pos:
			return false  # Position is part of the rotating group

	# Check if the position is occupied in the board matrix
	return board[pos.x][pos.y] != null  # Or any value that represents a filled cell

	
func rotate_blocks():
	# Choose a pivot block (usually the first in the group)
	var pivot = current_blocks[0]
	var new_positions = []
	
	for block in current_blocks:
		var relative_pos = block.grid_pos - pivot.grid_pos
		var rotated_pos = Vector2(-relative_pos.y, relative_pos.x)  # 90-degree clockwise rotation
		var target_pos = pivot.grid_pos + rotated_pos
		
		if not is_position_valid(target_pos):
			return  # Prevent rotation if any block is out of bounds

		new_positions.append(target_pos)

	# Apply the new positions after validation
	for i in range(current_blocks.size()):
		move_Block(current_blocks[i].grid_pos, new_positions[i])
		
