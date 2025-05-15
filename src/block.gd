extends Node2D
enum BlockType { RED, BLUE, GREEN, YELLOW }

var color_type: BlockType
var grid_pos: Vector2  # This will store the Block's position in the grid


# Function to assign a random type when spawned
func set_random_type():
	color_type = BlockType.values().pick_random()
	match color_type:
		BlockType.RED:
			$Sprite2D.texture = preload("res://assets/good_block_a.tres")
		BlockType.BLUE:
			$Sprite2D.texture = preload("res://assets/good_block_b.tres")
		BlockType.GREEN:
			$Sprite2D.texture = preload("res://assets/bad_block_a.tres")
		BlockType.YELLOW:
			$Sprite2D.texture = preload("res://assets/bad_block_b.tres")
