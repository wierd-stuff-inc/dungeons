extends Node2D

var Room = preload("res://Room.tscn")
### Tile szie
var tile_size = 32
### Room quantity
export (int) var room_quantity = 90
### Room minimum size (tiles)
export (int) var min_size = 4
### Room maximum size (tiles)
export (int) var max_size = 20
### Horizontal spread (pixels)
export (int) var horizontal_spread = 400
### Chance to delete room from 0 to 1.
export (float) var delete_chance = 0.5

var path_graph

func generate_rooms(): 
	"""
	Function to generate rooms inside $Rooms node.
	Algorithm:
		1. Generate random rooms. 
		2. Each room append to $Rooms node.
		3. Wait untill rooms will stop moving.
		4. Remove some rooms. 
		5. Make other rooms static. So they can't move.
		6. Build MST by looking at positions between remaining rooms.
		7. Connect rooms using tunnels.  
	Parameters
	----------
		None
	Return
	------
		void
	"""
	print("> Starting room generation")
	for i in range(room_quantity):
		var pos = Vector2(rand_range(-horizontal_spread, horizontal_spread), 0)
		var room_obj = Room.instance()
		var width = min_size + randi() % max_size
		var height = min_size + randi() % max_size
		room_obj.make_room(pos, Vector2(width, height) * tile_size)
		$Rooms.add_child(room_obj)
	print("> Waiting rooms to stop spreading")
	yield(get_tree().create_timer(2, true), "timeout")
	print("> Rooms genearted")	
	print("> Culling random rooms")
	var rooms_positions = []
	for room in $Rooms.get_children():
		if randf() < delete_chance:
			room.queue_free()
#			yield(get_tree().create_timer(0.1, true), "timeout")
		else:
			room.mode = RigidBody2D.MODE_STATIC
			rooms_positions.append(Vector3(room.position.x, room.position.y, 0))
	path_graph = build_mst(rooms_positions)

func build_mst(positions):
	"""
	Function to build minimum spanning tree using Prim's algorithm
	https://en.wikipedia.org/wiki/Prim%27s_algorithm
	Parameters
	----------
	positions : List[Vector3]
		Culled rooms positions.
	Returns
	-------
	Astar
		built minimum spanning tree graph.  
	"""
	var path = AStar.new()
	print("> Searching for the way!")
	path.add_point(path.get_available_point_id(), positions.pop_front())
	while positions:
		var minimum_distance = INF
		var minimum_point = null
		var current_pos = null
		for point in path.get_points():
			point = path.get_point_position(point)
			for availiable_point in positions:
				if point.distance_to(availiable_point) < minimum_distance:
					minimum_distance = point.distance_to(availiable_point)
					minimum_point = availiable_point
					current_pos = point
		var n = path.get_available_point_id()
		path.add_point(n, minimum_point)
		path.connect_points(path.get_closest_point(current_pos), n)
		positions.erase(minimum_point)
	print("Shortest way was found!")
	return path


func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color("#10d3a9"), false)
	if path_graph:
		for point in path_graph.get_points():
			for connect in path_graph.get_point_connections(point):
				var point_position = path_graph.get_point_position(point)
				var connection_position = path_graph.get_point_position(connect)
				draw_line(
					Vector2(point_position.x, point_position.y),
					Vector2(connection_position.x, connection_position.y),
					Color("#d310c0")
					)
		
### This update() will call `draw()` function when it was updated.
func _process(delta):
	update()
		
### Regenerate rooms when `spacebar` was pressed
func _input(event):
	if event.is_action_pressed('ui_select'):
		print("> Deleting rooms")
		for n in $Rooms.get_children():
			n.queue_free()
			path_graph = null
		generate_rooms()
		
### Turn on random engine and generate rooms.
func _ready():
	randomize()
	generate_rooms()