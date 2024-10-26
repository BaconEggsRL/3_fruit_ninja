extends Node2D

@export var score_label : Label
@export var new_best : Label
@export var num_bots_label : Label

@export var mouse_trail : Trail

@onready var fruits: Node2D = $fruits
const FRUIT = preload("res://fruit.tscn")
@onready var bombs: Node2D = $bombs
const BOMB = preload("res://bomb.tscn")

const LIFE_TEST = preload("res://life_test.tscn")
const COMBO_TEXT = preload("res://combo_text.tscn")


var score : int = 0
@export var num_bots : int = 2
const MAX_BOTS = 10
const MIN_BOTS = 0

const x_center = 1152/2.0 - 64
const y_center = 648 + 128

const MIN_SPEED = 1000
const MAX_SPEED = 1250

var min_wait_time = 0.5
var max_wait_time = 2.0

# 1 = 1.0
# 0 = 5.0
const MIN_MIN_BOMB = 0.1
const MAX_MIN_BOMB = 3.0
const DEFAULT_MIN_BOMB = MAX_MIN_BOMB

const MIN_MAX_BOMB = 0.5
const MAX_MAX_BOMB = 6.0
const DEFAULT_MAX_BOMB = MAX_MAX_BOMB


var min_bomb_wait_time = DEFAULT_MIN_BOMB
var max_bomb_wait_time = DEFAULT_MAX_BOMB
@export var bomb_slider : HSlider
const default_bomb_slider_value = 0.0
var bomb_slider_value

const FRUIT_SPREAD = 250
const BOMB_SPREAD = FRUIT_SPREAD

const HEART = preload("res://assets/emote_heart.png")
const HEART_BROKEN = preload("res://assets/emote_heartBroken.png")
const MAX_LIVES : int = 3
var lives_left := MAX_LIVES
@export var hearts_container : HBoxContainer
var hearts_array : Array[TextureRect]

var is_game_over : bool = false
@export var gameover_canvas : CanvasLayer

var multi_slice_count:int = 0
var slice_position:Vector2 = Vector2(0,0)
@export var combo_timer:Timer

var combo_color = Color(1, 1, 93.0/255.0, 1)
var crit_color = Color(62.0/255.0, 1, 1, 1)




func start_bomb_timer() -> void:
	var bomb_timer = Timer.new()
	bomb_timer.one_shot = true
	bomb_timer.wait_time = randf_range(min_bomb_wait_time, max_bomb_wait_time)
	bomb_timer.timeout.connect(_on_bomb_timer_timeout.bind(bomb_timer))
	self.add_child(bomb_timer)
	bomb_timer.start()
			
			
func _on_bomb_timer_timeout(bomb_timer:Timer) -> void:
	# on completed timer, make new fruit
	var pos = Vector2(x_center + randf_range(-BOMB_SPREAD, BOMB_SPREAD), y_center)
	# var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
	make_bomb(pos)
	# change wait time
	bomb_timer.wait_time = randf_range(min_bomb_wait_time, max_bomb_wait_time)
	bomb_timer.start()



func player_scored(score_amount:int = 1) -> void:
	score += score_amount
	score_label.text = str(score)
	if score > Global.save_data.classic_high_score:
		self.new_best.show()
		Global.save_data.classic_high_score = score
		Global.save_data.save()
		
		
func fruit_connect(f: Fruit) -> void:
	f.test_mouse_entered.connect(mouse_trail._on_fruit_entered)
	f.test_mouse_exited.connect(mouse_trail._on_fruit_exited)
func bomb_connect(b: Bomb) -> void:
	b.test_mouse_entered.connect(mouse_trail._on_fruit_entered)
	b.test_mouse_exited.connect(mouse_trail._on_fruit_exited)




########################################################################


func _ready() -> void:
	Global.current_scene = self
	new_best.hide()
	gameover_canvas.hide()
	
	# make bots
	self.num_bots = Global.save_data.num_bots
	num_bots_label.text = str(num_bots)
	for i in range(num_bots):
		make_fruit()
		
	# mouse trail slice
	mouse_trail.slice.connect(_on_slice)
	
	# get hearts array
	for c in hearts_container.get_children():
		hearts_array.append(c)
		# print(hearts_array)
	
	# set default bomb slider value
	bomb_slider.value = Global.save_data.bomb_slider_value
	
	# start making bombs
	start_bomb_timer()
	
	
	
	# change background color
	# RenderingServer.set_default_clear_color(Color(0,0,0,1))



func make_fruit(pos := Vector2(x_center, y_center), 
				vel := Vector2(0, randf_range(MIN_SPEED, MAX_SPEED))) -> void:
	# spawn a new fruit
	if not is_game_over:
		var f = FRUIT.instantiate()
		f.position = pos
		f.apply_central_impulse(-1*vel)
		fruits.call_deferred("add_child", f)
		fruit_connect(f)
func make_bomb(pos := Vector2(x_center, y_center), 
				vel := Vector2(0, randf_range(MIN_SPEED, MAX_SPEED))) -> void:
	# spawn a new fruit
	if not is_game_over:
		var b = BOMB.instantiate()
		b.position = pos
		b.apply_central_impulse(-1*vel)
		bombs.call_deferred("add_child", b)
		bomb_connect(b)


	
func _on_slice(fruit_path, in_glob, out_glob) -> void:
	
	# cut the fruit (or bomb)
	var cut_fruit = get_node(fruit_path)
	cut_fruit.cut(in_glob, out_glob)

	# create new fruit and increment score
	var fruit_or_bomb = get_node(fruit_path)
	
	if not is_game_over:
	
		if fruit_or_bomb.is_in_group("fruit"):
			
			var fruit : Fruit = fruit_or_bomb
			
			# start the respawn fruit timer
			var fruit_timer = Timer.new()
			fruit_timer.one_shot = true
			fruit_timer.wait_time = randf_range(min_wait_time, max_wait_time+num_bots/2.0)
			fruit_timer.timeout.connect(_on_fruit_timer_timeout.bind(fruit_timer))
			self.add_child(fruit_timer)
			fruit_timer.start()
			
			# increment score
			player_scored(1)
				
			# start the multi-slice combo timer
			if multi_slice_count == 0:
				combo_timer.start()
			# inc slice count
			multi_slice_count += 1
			slice_position = fruit.position
			
			# check if critical hit (sliced fruit overlapping with bomb)
			var areas = fruit.area_2d.get_overlapping_areas()
			# print("areas = ", areas)
			for a in areas:
				print(a.name)
				if a.name == "CritArea":
					var combo_text = COMBO_TEXT.instantiate()
					var combo_score = 10
					var label = combo_text.get_node("Label")
					label.set("theme_override_colors/font_color", crit_color)
					label.text = "CRIT! +%s" % str(combo_score)
					combo_text.position = slice_position
					call_deferred("add_child", combo_text)
					# increment score
					player_scored(combo_score)
					# Global.play_sound("crit", false)
				
			
	
	
				
		elif fruit_or_bomb.is_in_group("bomb"):
			# trigger explosion / lose a life
			# if fruit not sliced, lose a life
			if lives_left > 0:
				hearts_array[MAX_LIVES - lives_left].texture = HEART_BROKEN
				lives_left -= 1
				var lt = LIFE_TEST.instantiate()
				lt.position = fruit_or_bomb.position
				call_deferred("add_child", lt)
				# Global.play_sound("hit_hurt", false)
				
				if lives_left == 0:
					_on_game_over()
			
		else:
			print("wtf did you cut")
	
	

func _on_fruit_timer_timeout(fruit_timer:Timer) -> void:
	# on completed timer, make new fruit
	var pos = Vector2(x_center + randf_range(-FRUIT_SPREAD, FRUIT_SPREAD), y_center)
	# var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
	make_fruit(pos)
	# delete timer
	fruit_timer.call_deferred("queue_free")



# fruit is out of bounds
func _on_bounds_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("fruit"):
		# print("body out of bounds, ", body)
		if body.sliced == false:
			
			# if fruit not sliced, lose a life
			if lives_left > 0:
				hearts_array[MAX_LIVES - lives_left].texture = HEART_BROKEN
				lives_left -= 1
				Global.play_sound("hit_hurt", false)
				var lt = LIFE_TEST.instantiate()
				lt.position.x = body.position.x
				lt.position.y = 475
				call_deferred("add_child", lt)
				
				if lives_left == 0:
					_on_game_over()
			
			if not is_game_over:
				# print("NOT SLICED")
				var pos = Vector2(x_center + randf_range(-FRUIT_SPREAD, FRUIT_SPREAD), y_center)
				# var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
				make_fruit(pos)
	body.call_deferred("queue_free")



func _on_game_over() -> void:
	print("GAME OVER")
	is_game_over = true
	gameover_canvas.show()
	
	
	
func _on_reset_button_pressed() -> void:
	Global.to_classic()


func _on_back_button_pressed() -> void:
	Global.to_main()


func _on_inc_num_bots_pressed() -> void:
	if not is_game_over:
		var temp = num_bots + 1
		if temp > MAX_BOTS:
			return
		else:
			num_bots = temp
			num_bots_label.text = str(num_bots)
			Global.save_data.num_bots = num_bots
			Global.save_data.save()
			var pos = Vector2(x_center + randf_range(-FRUIT_SPREAD, FRUIT_SPREAD), y_center)
			# var vel = Vector2(0, clamp(randf_range(0, 700), 0, MAX_SPEED))
			make_fruit(pos)


func _on_dec_num_bots_pressed() -> void:
	if not is_game_over:
		var temp = num_bots - 1
		if temp < MIN_BOTS:
			return
		else:
			
			for f in fruits.get_children():
				if f.sliced == false:
					f.call_deferred("queue_free")
					num_bots = temp
					num_bots_label.text = str(num_bots)
					Global.save_data.num_bots = num_bots
					Global.save_data.save()
					return


# bomb slider value between 0 and 1
func _on_bomb_slider_value_changed(value: float) -> void:
	bomb_slider_value = value
	var N = 1.0  # max value
	var A = 2.71828  # curviness / ramp factor (growth speed) -- between 1.0 and 10.0
	var B = (1.0 + 1.0/A)  # coefficient based on A
	var scaled_value = B*(N - N/(A*value + 1))
	
	
	max_bomb_wait_time = remap(scaled_value, 0, 1, MAX_MAX_BOMB, MIN_MAX_BOMB)
	min_bomb_wait_time = remap(scaled_value, 0, 1, MAX_MIN_BOMB, MIN_MIN_BOMB)
	
	Global.save_data.bomb_slider_value = value
	Global.save_data.save()


func _on_combo_timer_timeout() -> void:
	# print("slice count = ", multi_slice_count)
	if multi_slice_count > 1:
		var combo_text = COMBO_TEXT.instantiate()
		var combo_score = pow(multi_slice_count, 2)
		var label = combo_text.get_node("Label")
		label.set("theme_override_colors/font_color", combo_color)
		label.text = "COMBO! +%s" % str(combo_score)
		combo_text.position = slice_position
		call_deferred("add_child", combo_text)
		# increment score
		player_scored(combo_score)
		# Global.play_sound("combo", false)
			
				
	multi_slice_count = 0
