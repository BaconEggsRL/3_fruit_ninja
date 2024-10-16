class_name MouseTrail
extends Line2D

const MAX_POINTS: int = 500
@onready var curve := Curve2D.new()

var dragging := false


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Start dragging if the button is pressed
		if not dragging and event.pressed:
			dragging = true
			make_trail()
			
		# Stop dragging if the button is released.
		if dragging and not event.pressed:
			dragging = false
			

	if event is InputEventMouseMotion and dragging:
		pass
		
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	curve.add_point(mouse_pos)
	
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	
	points = curve.get_baked_points()


# stop rendering trail
func stop() -> void:
	set_process(false)
	var tw := get_tree().create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.0)
	await tw.finished
	queue_free()
	
	
# create a trail
static func create() -> MouseTrail:
	var scn = preload("res://mouse_trail.tscn")
	return scn.instantiate()
