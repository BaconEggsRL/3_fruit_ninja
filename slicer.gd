extends Node2D


# @onready var limit = get_node("Limit")
# @onready var interval = get_node("Interval")

var pressed = false
var drag = false
var curPosition = Vector2(0, 0)
var prevPosition = Vector2(0, 0)

var gameOver = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	#For coordinates to fit the local device screen
	event = make_input_local(event)
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_pressed(event.position)
		else:
			_on_released()
	elif event is InputEventScreenDrag:
		_on_drag(event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	queue_redraw()
	if drag and curPosition != prevPosition and prevPosition != Vector2(0, 0) and not gameOver:
		var space_state = get_world_2d().get_direct_space_state()
		# Returns a list of objects the ray encounters on its way
		var parameters = PhysicsRayQueryParameters2D.create(prevPosition, curPosition)
		var result = space_state.intersect_ray(parameters)
		if result:
			# call cut function from the collided object which is the fruit
			result.collider.cut()

func _on_pressed(pos):
	pressed = true
	prevPosition = pos
	# limit.start()
	# interval.start()


func _on_released():
	pressed = false
	drag = false
	# limit.stop()
	# interval.stop()
	prevPosition = Vector2(0, 0)
	curPosition = Vector2(0, 0)


func _on_drag(pos):
	curPosition = pos
	drag = true


func _on_Interval_timeout():
	prevPosition = curPosition


func _on_Limit_timeout():
	_on_released()


func _draw():
	if drag and curPosition != prevPosition and prevPosition != Vector2(0, 0) and not gameOver:
		draw_line(curPosition, prevPosition, Color(1, 0 ,0), 10)
