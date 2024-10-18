class_name Fruit
extends RigidBody2D

signal test_mouse_entered
signal test_mouse_exited

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D
@onready var image: Image = sprite_2d.texture.get_image()
@onready var size: Vector2i = image.get_size()

@onready var x_offset = 0 # -1.75 * (size.x / 2.0)
@onready var y_offset = 0 # -1 * (size.y / 2.0)

var baked_polygons
var entered_point
var exited_point
var sliced : bool = false
@onready var poly_container: Node2D = $poly_container
@onready var slice_container: Node2D = $slice_container

# const FRUIT = preload("res://fruit.tscn")
# @onready var fruit_timer: Timer = $FruitTimer



func reset() -> void:
	# print("reset")
	baked_polygons = null
	entered_point = null
	exited_point = null
	sliced = false
	
	for p in poly_container.get_children():
		poly_container.remove_child(p)
		p.queue_free()
	
	for s in slice_container.get_children():
		slice_container.remove_child(s)
		s.queue_free()
		
	self.sprite_2d.show()



func _ready() -> void:
	reset()
	

######################################################

static func draw_point(pos:Vector2, radius = 4, color = Color.RED) -> MeshInstance2D:
	var mesh_instance := MeshInstance2D.new()
	
	# mesh required for rending, color comes from canvas modulate
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2

	# apply
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	mesh_instance.modulate = color

	return mesh_instance



func get_polygons() -> Array[PackedVector2Array]:
	if !baked_polygons:
		var bitmap = BitMap.new()
		# Create bitmap from the Sprite2D texture image
		bitmap.create_from_image_alpha(image)
		# generate the polygons
		var polygons = bitmap.opaque_to_polygons(image.get_used_rect())
		baked_polygons = polygons
	return baked_polygons
	
	
static func get_offset_polyline(glob_in: Vector2, glob_out: Vector2) -> Array[PackedVector2Array]:
	# Create a line from top-left to bottom-right
	var polyline = [glob_in, glob_out]
	# print("polyline[0] = ", polyline)
	# offset it 1 pixel (inflate) to convert it to polygons
	# this creates a rectangle of 1 pixel width for the slice
	polyline = Geometry2D.offset_polyline(polyline, 1)
	return polyline





func get_slice(points : PackedVector2Array, width = 2, color = Color.WHITE_SMOKE) -> Line2D:
	var slice = Slice.new()
	slice.points = points
	
	var slope = slice.get_slope()
	# print("slope = ", slope)
	
	
	slice.width = width
	slice.default_color = color
	# slice_container.add_child(slice)
	# print("slice = ", slice.points)
	return slice


func draw_points(point_array : PackedVector2Array) -> void:
	
	for i in point_array.size():
		
		if i == 0:
			var mesh_instance = draw_point(point_array[i], 4, Color.GREEN)
			slice_container.add_child(mesh_instance)
		else:
			var mesh_instance = draw_point(point_array[i])
			slice_container.add_child(mesh_instance)
		
		


func cut(glob_in: Vector2, glob_out: Vector2) -> void:
	
	var loc_in = to_local(glob_in)
	var loc_out = to_local(glob_out)
	
	self.sliced = true
	
	# self.sprite_2d.hide()
	
	var polyline : Array[PackedVector2Array] = get_offset_polyline(loc_in, loc_out)
	print("polyline[0] = ", polyline[0])
	
	var slice = get_slice([loc_in, loc_out])
	
	# add slice and points
	slice_container.add_child(slice)
	draw_points(slice.points)
	
	# test
	var dx = size.x * 2
	var point1 = Vector2(slice.points[0].x + dx, slice.points[0].y - dx*slice.slope)
	var mesh_instance1 = draw_point(point1, 4, Color.PURPLE)
	slice_container.add_child(mesh_instance1)
	slice.add_point(point1)
	
	var point2 = Vector2(slice.points[0].x - dx, slice.points[0].y + dx*slice.slope)
	var mesh_instance2 = draw_point(point2, 4, Color.PURPLE)
	slice_container.add_child(mesh_instance2)
	slice.add_point(point2)
	
	print("points = ", slice.points)
	
	# sort points from min x to max x
	var sorted = slice.points
	sorted.sort()
	print("sorted = ", sorted)
	
	# get new polyline based on test
	polyline = get_offset_polyline(sorted[0], sorted[-1])
	print("new polyline[0] = ", polyline[0])
	
	


	var polygons = get_polygons()
	
	var y = 0
	for polygon in polygons:
		# clip each polygon from the Sprite2D image with the polyline
		var splits = Geometry2D.clip_polygons(polygon, polyline[0])
		var x = 0
		
		# print("splits = ", splits)
		for split in splits:
			# For each split create a new Polygon2D with the Sprite2D texture
			var poly = Polygon2D.new()
			poly.global_position.x = x + x_offset
			poly.global_position.y = y + y_offset
			poly.polygon = split
			poly.texture = sprite_2d.texture
			
			var body = RigidBody2D.new()
			var collider = CollisionPolygon2D.new()
			collider.polygon = split
			# collider.disabled = true
			body.set_collision_layer_value(1, false)
			body.set_collision_mask_value(1, false)
			body.set_collision_layer_value(2, true)
			
			self.set_collision_layer_value(1, false)
			self.set_collision_mask_value(1, false)
			self.set_collision_layer_value(2, true)
			# body.set_collision_mask_value(2, true)
			
			body.add_child(poly)
			body.add_child(collider)
			
			poly_container.add_child(body)
			var x_impulse = randf_range(50, 500) * [-1, 1].pick_random()
			var y_impulse = randf_range(-400, 200)
			body.apply_impulse(Vector2(x_impulse,y_impulse))
			
			x += 1

		y += 1
		
		# make original shape invsible
		$Sprite2D.hide()
		$Area2D.hide()
		$CollisionShape2D.hide()
		
		# add a new child to slice
		# completed_cut.emit()
		
		# play sound
		Global.play_sound("slice", false)


func _on_area_2d_mouse_entered() -> void:
	# print("entered Area")
	test_mouse_entered.emit(self.get_path())


func _on_area_2d_mouse_exited() -> void:
	# print("left Area")
	test_mouse_exited.emit(self.get_path())
