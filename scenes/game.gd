extends Node2D

@export var score_label : Label
@export var new_best : Label
@export var num_bots_label : Label

@export var mouse_trail : Trail

@onready var fruits: Node2D = $fruits
const FRUIT = preload("res://fruit.tscn")

var score : int = 0
@export var num_bots : int = 2
const MAX_BOTS = 10
const MIN_BOTS = 0

const x_center = 1152/2.0 - 64
const y_center = -128
const MAX_SPEED = 500


func player_scored() -> void:
	score += 1
	score_label.text = str(score)
		
		
func fruit_connect(f: Fruit) -> void:
	f.test_mouse_entered.connect(mouse_trail._on_fruit_entered)
	f.test_mouse_exited.connect(mouse_trail._on_fruit_exited)
	
	
func _ready() -> void:
	Global.current_scene = self
	new_best.hide()
	
	# make bots
	num_bots_label.text = str(num_bots)
	for i in range(num_bots):
		make_fruit()
		
	# mouse trail slice
	mouse_trail.slice.connect(_on_slice)
	
	# change background color
	# RenderingServer.set_default_clear_color(Color(0,0,0,1))



func make_fruit(pos := Vector2(x_center, y_center), vel := Vector2(0, MAX_SPEED)) -> void:
	# spawn a new fruit
	var f = FRUIT.instantiate()
	f.position = pos
	f.apply_central_impulse(vel)
	fruits.call_deferred("add_child", f)
	fruit_connect(f)
	
	
func _on_slice(fruit_path, in_glob, out_glob) -> void:
	var cut_fruit = get_node(fruit_path)
	cut_fruit.cut(in_glob, out_glob)
	# on completed cut: make a new fruit
	var pos = Vector2(x_center + randf_range(-200, 200), y_center)
	var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
	make_fruit(pos, vel)
	
	# increment score
	player_scored()
	if score > Global.save_data.sandbox_high_score:
		self.new_best.show()
		Global.save_data.sandbox_high_score = score
		Global.save_data.save()
	
	


func _on_bounds_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("fruit"):
		# print("body out of bounds, ", body)
		if body.sliced == false:
			print("NOT SLICED")
			var pos = Vector2(x_center + randf_range(-200, 200), y_center)
			var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
			make_fruit(pos, vel)
	body.call_deferred("queue_free")


func _on_reset_button_pressed() -> void:
	Global.to_sandbox()


func _on_back_button_pressed() -> void:
	Global.to_main()


func _on_inc_num_bots_pressed() -> void:
	var temp = num_bots + 1
	if temp > MAX_BOTS:
		return
	else:
		num_bots = temp
		num_bots_label.text = str(num_bots)
		var pos = Vector2(x_center + randf_range(-200, 200), y_center)
		var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
		make_fruit(pos, vel)


func _on_dec_num_bots_pressed() -> void:
	var temp = num_bots - 1
	if temp < MIN_BOTS:
		return
	else:
		
		for f in fruits.get_children():
			if f.sliced == false:
				f.call_deferred("queue_free")
				num_bots = temp
				num_bots_label.text = str(num_bots)
				return
