class_name Slice
extends Line2D

var slope : float


func _ready() -> void:
	pass


func get_slope() -> float:
	
	assert(points.size() >= 2)
	
	var p1 = points[0]
	var p2 = points[-1]
	var dy = -1 * (p2.y - p1.y)
	var dx = p2.x - p1.x
	
	if dx == 0:
		self.slope = 50
		print("INF SLOPE")
		return self.slope
	else:
		self.slope = dy/dx
		return self.slope
