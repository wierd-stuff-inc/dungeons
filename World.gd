extends Node2D

var Room = preload("res://Room.tscn")
### Tile szie
var tile_size = 32
### Room quantity
export (int) var room_quantity = 55
### Room minimum size
export (int) var min_size = 4
### Room maximum size
export (int) var max_size = 20
export (int) var horizontal_spread = 400
### Chance to delete room from 0 to 1.
export (float) var delete_chace = 0.5
 
func generate_rooms(): 
	for i in range(room_quantity):
		var pos = Vector2(rand_range(-horizontal_spread, horizontal_spread), 0)
		var room_obj = Room.instance()
		var width = min_size + randi() % max_size
		var height = min_size + randi() % max_size
		room_obj.make_room(pos, Vector2(width, height) * tile_size)
		$Rooms.add_child(room_obj)

### Draw rectangle shapes for all generated rooms.
func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(150, 32, 78), false)
		
### This update() will call `draw()` function when it was updated.
func _process(delta):
	update()
		
### Regenerate rooms when `spacebar` was pressed
func _input(event):
	if event.is_action_pressed('ui_select'):
		for n in $Rooms.get_children():
			n.queue_free()
		generate_rooms()
		
### Turn on random engine and generate rooms.
func _ready():
	randomize()
	generate_rooms()