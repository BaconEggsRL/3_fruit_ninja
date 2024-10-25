extends Node2D

@export var mouse_trail : Trail
@onready var fruits: Node2D = $fruits
const FRUIT = preload("res://fruit.tscn")
const x_center = 1152/2.0 - 64
const y_center = -128
const MAX_SPEED = 0



func _ready() -> void:
	# Set the current scene
	Global.current_scene = self
	
	# make fruit
	mf_test()
	# get 2nd fruit
	start_respawn_timer(0.05)
	# get 3rd fruit
	# start_respawn_timer(0.05)
	
	# mouse trail slice
	mouse_trail.slice.connect(_on_slice)


func start_respawn_timer(wt: float = randf_range(1.0, 3.0)) -> Timer:
	var fruit_timer = Timer.new()
	fruit_timer.wait_time = wt
	fruit_timer.one_shot = true
	fruit_timer.timeout.connect(_on_fruit_timer_timeout)
	add_child(fruit_timer)
	fruit_timer.start()
	return fruit_timer


func mf_test() -> void:
	var pos = Vector2(x_center + randf_range(-450, 450), y_center)
	var vel = Vector2(0, MAX_SPEED)
	make_fruit(pos, vel)


func fruit_connect(f: Fruit) -> void:
	f.test_mouse_entered.connect(mouse_trail._on_fruit_entered)
	f.test_mouse_exited.connect(mouse_trail._on_fruit_exited)
	
func make_fruit(pos := Vector2(x_center, y_center), vel := Vector2(0, MAX_SPEED)) -> void:
	# spawn a new fruit
	var f = FRUIT.instantiate()
	f.position = pos
	f.apply_central_impulse(vel)
	fruits.call_deferred("add_child", f)
	fruit_connect(f)
	

# after slice don't spawn another until timer completes
func _on_fruit_timer_timeout() -> void:
	mf_test()
	
	
	
func _on_slice(fruit_path, in_glob, out_glob) -> void:
	var cut_fruit = get_node(fruit_path)
	cut_fruit.cut(in_glob, out_glob)
	# on completed cut: make a new fruit
	start_respawn_timer()
	


func _on_bounds_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("fruit"):
		print("body out of bounds, ", body)
		if body.sliced == false:
			print("NOT SLICED")
			mf_test()
	body.call_deferred("queue_free")




#################################################
# UI

func _on_scores_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_scores()


func _on_credits_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_credits()


func _on_settings_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_settings()


func _on_arcade_btn_pressed() -> void:
	Global.play_sound("button")
	Global.to_arcade()


func _on_classic_btn_pressed() -> void:
	Global.play_sound("button")
	Global.to_classic()
