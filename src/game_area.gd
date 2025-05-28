extends Node2D
# Nodes representing the grid limits and cell reference
@onready var bottom_left = $bottomLeftLimit
@onready var top_right = $topRightLimit
@onready var cell_top_right = $cellToprightLimit

# Preload a texture for the sprites
var sprite_texture = preload("res://assets/backgroundBlock.png")  # Replace with the actual texture path



# Function to get the size of a single cell
func get_cell_size() -> Vector2:
	return cell_top_right.position - bottom_left.position

# Function to get the grid size
func get_grid_size() -> Vector2:
	return top_right.position - bottom_left.position

# Function to get the number of cells in each axis
func get_grid_dimensions() -> Vector2:
	var cell_size = get_cell_size()
	var grid_size = get_grid_size()
	return Vector2(int(grid_size.x / cell_size.x), int(grid_size.y / cell_size.y))

# Function to get the center position of a specific cell
func get_cell_center(cell_x: int, cell_y: int) -> Vector2:
	var cell_size = get_cell_size()
	var cell_position = bottom_left.position + Vector2(cell_x * cell_size.x, cell_y * cell_size.y)
	return cell_position + cell_size / 2


# NOT USED Function to spawn a Sprite2D at the center of each cell and scale it to fit
func spawn_sprites():
	var grid_dimensions = get_grid_dimensions()
	var cell_size = get_cell_size()

	for x in range(int(grid_dimensions.x)):
		for y in range(int(grid_dimensions.y)):
			var sprite = Sprite2D.new()
			sprite.texture = sprite_texture
			sprite.position = get_cell_center(x, y)
			
			# Scale the sprite to fit the cell size
			var texture_size = sprite.texture.get_size()
			sprite.scale = Vector2(- cell_size.x / texture_size.x, - cell_size.y / texture_size.y)

			add_child(sprite)
