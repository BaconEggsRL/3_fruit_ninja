extends Node2D

@export var best_score : Label

@onready var audio_popup: ConfirmationDialog = $AudioPopup
@onready var score_popup: ConfirmationDialog = $ScorePopup

@export var music : RichTextLabel
@export var code : RichTextLabel

@export var mouse_trail : Trail
@onready var fruits: Node2D = $fruits
const FRUIT = preload("res://fruit.tscn")
const x_center = 1152/2.0 - 64
const y_center = -128
const MAX_SPEED = 0



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
	
	
	
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the current scene
	Global.current_scene = self
	audio_popup.hide()
	score_popup.hide()
	# Load audio and high score data
	best_score.text = "%s" % str(Global.save_data.high_score)
	# sliders call _set_slider_value_from_bus() in ready function
	
	# meta links
	music.meta_clicked.connect(_on_music_meta_clicked)
	code.meta_clicked.connect(_on_code_meta_clicked)
	
	
	# make fruit
	mf_test()
	# get 2nd fruit
	start_respawn_timer(0.05)
	# get 3rd fruit
	# start_respawn_timer(0.05)
	
	# mouse trail slice
	mouse_trail.slice.connect(_on_slice)
	
	


func _on_music_meta_clicked(meta: Variant) -> void:
	open_meta_link(meta)


func _on_code_meta_clicked(meta: Variant) -> void:
	open_meta_link(meta)
	

# Conert a meta link to string and open in new tab
func open_meta_link(meta: Variant) -> void:
	print("meta = ", meta)
	print("OS name = ", OS.get_name())
	if OS.get_name() != "Web":
		print("not Web")
		OS.shell_open(str(meta))
	else:
		print("is Web")
		var eval_str = "window.open('%s', '_blank');" % str(meta)
		JavaScriptBridge.eval(eval_str)
		
		
func _on_back_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_main()


################################################
# confirm dialogs


func _on_reset_audio_pressed() -> void:
	audio_popup.show()


func _on_reset_score_pressed() -> void:
	score_popup.show()


func _on_audio_popup_confirmed() -> void:
	Global.save_data.bus_volume = {
		"Master": 0.5,
		"music": 1,
		"sfx": 1,
	}
	Global.save_data.save()

	Global.set_bus_volume()
	var sliders = get_tree().get_nodes_in_group("volume_slider")
	for s in sliders:
		s._set_slider_value_from_bus()


func _on_score_popup_confirmed() -> void:
	Global.save_data.high_score = 0
	Global.save_data.save()
	best_score.text = "%s" % str(Global.save_data.high_score)


func _on_more_games_pressed() -> void:
	var link = "https://baconeggsrl.itch.io/"
	open_meta_link(link)
