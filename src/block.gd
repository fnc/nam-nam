class_name BlockPair extends Node2D
enum BlockType { RED, BLUE, GREEN, YELLOW }

@export var block_textures: Array[Texture]
@export var block_sprite: Sprite2D

var color_type: BlockType
var grid_pos: Vector2  # This will store the Block's position in the grid

# Function to assign a random type when spawned
func set_random_type():
	color_type = BlockType.values().pick_random()
	match color_type:
		BlockType.RED:
			block_sprite.texture = block_textures[0]
		BlockType.BLUE:
			block_sprite.texture = block_textures[1]
		BlockType.GREEN:
			block_sprite.texture = block_textures[2]
		BlockType.YELLOW:
			block_sprite.texture = block_textures[3]
		_:
			block_sprite.texture = block_textures[3]
