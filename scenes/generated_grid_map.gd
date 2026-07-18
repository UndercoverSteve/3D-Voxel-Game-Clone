extends GridMap

func destroy_block(world_coordinate):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, -1)

func place_block(world_coordinate, block_index):
	var map_coordinate = local_to_map(world_coordinate)
	set_cell_item(map_coordinate, block_index)
	print("Setting Cell")

const CHUNK_SIZE = 16
const BASE = 0
const AMPLITUDE = 8
const VIEW_DISTANCE = 2

var loaded_chunks := {} #Vector2i -> true
var last_player_chunk = null # detect when player crosses a boundary

var noise := FastNoiseLite.new()

@onready var player: CharacterBody3D = $"../Player"

###func old_generate_chunk(cx: int, cz: int) -> void:
#	for world_x in range(cx * 16, (cx * 16) + 16):
#		for world_y in range(-3, 0):
#			for world_z in range(cz * 16, (cz * 16) + 16):
#				print("cool")
#				var map_coordinate = Vector3(world_x, world_y, world_z)
###				set_cell_item(map_coordinate, 0)
		
func generate_chunk(cx: int, cz: int) -> void:
	for local_x in range(CHUNK_SIZE):
		for local_z in range(CHUNK_SIZE):
			var world_x = cx * CHUNK_SIZE + local_x
			var world_z = cz * CHUNK_SIZE + local_z
			
			var n = noise.get_noise_2d(world_x, world_z) # -1.0 to 1.0
			var height = BASE + int(n * AMPLITUDE)
			
			var y_index = 0 # How many times the for loop has looped
			for world_y in range(height, -12, -1): # fill column bottum-up to height
				var block_index
				
				if y_index == 0: # Top to bottom
					block_index = 3 # Grass block
				elif y_index <= 3:
					block_index = 2 # Dirt Block
				else:
					block_index = 4 # Stone Block
				
				set_cell_item(Vector3i(world_x, world_y, world_z), block_index)
				y_index += 1

func generate_simple_chunk():
	for x in range(-8, 8):
		for y in range(-253, 3):
			for z in range(-8, 8):
				var map_coordinate = Vector3(x, y, z)
				set_cell_item(map_coordinate, 0)

func get_player_chunk() -> Vector2i:
	var player_pos = to_local(player.global_position)
	var cell = local_to_map(player_pos)
	var cx = floori(cell.x / float(CHUNK_SIZE))
	var cz = floori(cell.z / float(CHUNK_SIZE))
	return Vector2i(cx, cz)

func update_chunks() -> void:
	var current = get_player_chunk()
	if current == last_player_chunk:
		return # player didn't change chunk, return
	last_player_chunk = current
	
	for cx in range(current.x - VIEW_DISTANCE, current.x + VIEW_DISTANCE + 1):
		for cz in range(current.y - VIEW_DISTANCE, current.y + VIEW_DISTANCE + 1):
			var key = Vector2i(cx, cz)
			if not loaded_chunks.has(key):
				generate_chunk(cx, cz)
				loaded_chunks[key] = true

func _process(delta: float) -> void:
	update_chunks()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = 1337 #seed
	noise.frequency = 0.05 # lower = broader/smooth, higher is opposite
	update_chunks()
	
