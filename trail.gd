extends Line2D
class_name Trail

var queue : Array
@export var MAX_LENGTH : int = 50

var dragging : bool = false
var moving : bool = false
var was_last_dragging : bool = false

const MIN_MOVE_SPEED : float = 0.0
const SWIPE_SPEED : float = 4000.0

signal slice

var can_swipe : bool = true



func _ready() -> void:
	# MOUSE_MODE_VISIBLE
	# print("mouse_mode = ", Input.mouse_mode)
	
	if Global.mobile:
		self.width = 32
	else:
		self.width = 32



# detect if dragging
func _input(event):
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		# If pressed
		if event.pressed:
			
			# Start dragging if not dragging
			if not dragging:
				dragging = true
				# print("Dragging")
				
		else:
			# Stop dragging if the button is released
			if dragging:
				dragging = false
				# print("Released")
	
	
	# Mouse is moving while dragging
	if Global.mobile:
		if event is InputEventScreenDrag and dragging:
			moving = true
		else:
			moving = false
	else:
		if event is InputEventMouseMotion and dragging:
			moving = true
		else:
			moving = false
		
		
		

# update trail
func _process(_delta):
	
	# remove points
	if not moving or queue.size() > MAX_LENGTH:
		_remove_point_from_queue()
	# add current point to the queue if dragging
	if moving:
		_add_point_to_queue()
		var mouse_speed = Input.get_last_mouse_velocity().length()
		if mouse_speed > SWIPE_SPEED and can_swipe:
			Global.play_swipe()
			$SwipeTimer.start()
			can_swipe = false
	# clear the line and draw only points in queue every frame
	_clear_and_draw_queue()
	
	




# clear the line and draw only points in queue every frame
func _clear_and_draw_queue():
	clear_points()
	for point in queue:
		add_point(point)

# add current point to queue and remove last point
func _remove_point_from_queue():
	if queue.size() > 0:
		queue.pop_back()
		
# add current point to queue and remove last point
func _add_point_to_queue(pos : Vector2 = self._get_position()):
	queue.push_front(pos)
	if queue.size() > MAX_LENGTH:
		queue.pop_back()

# get position (normally follow mouse position, but can override this)
func _get_position():
	return get_global_mouse_position()



# triggered when mouse enters a fruit
func _on_fruit_entered(fruit_path) -> void:
	var fruit = get_node(fruit_path)
	
	if not fruit.sliced:
		# print("entered ", fruit_path)
		if dragging:
			fruit.entered_point = _get_position()
			# print("at ", fruit.entered_point)


func _on_fruit_exited(fruit_path) -> void:
	var fruit = get_node(fruit_path)
	
	if not fruit.sliced:
		# print("exited ", fruit_path)
		if dragging and fruit.entered_point:
			fruit.exited_point = _get_position()
			# print("slice")
			slice.emit(fruit_path, fruit.entered_point, fruit.exited_point)


func _on_swipe_timer_timeout() -> void:
	can_swipe = true
