extends RigidBody2D

var size
var last_pos
func make_room(pos, _size):
	position = pos
	last_pos = pos
	size = _size
	var shape = RectangleShape2D.new()
	shape.custom_solver_bias = 0.8
	shape.extents = _size
	$CollisionShape2D.shape = shape