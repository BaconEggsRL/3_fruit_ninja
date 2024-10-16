extends Node2D

@export var start_fruit : Fruit
@export var mouse_trail : Trail

@onready var fruits: Node2D = $fruits
const FRUIT = preload("res://fruit.tscn")


func fruit_connect(f: Fruit) -> void:
	f.test_mouse_entered.connect(mouse_trail._on_fruit_entered)
	f.test_mouse_exited.connect(mouse_trail._on_fruit_exited)
	
	
func _ready() -> void:
	Global.current_scene = self
	
	fruit_connect(start_fruit)
	mouse_trail.slice.connect(_on_slice)
	
	# change background color
	# RenderingServer.set_default_clear_color(Color(0,0,0,1))


func _on_slice(fruit_path, in_glob, out_glob) -> void:
	var cut_fruit = get_node(fruit_path)
	cut_fruit.cut(in_glob, out_glob)
	# on completed cut: make original shape invisible and spawn new fruit
	var f = FRUIT.instantiate()
	f.position = Vector2(1152/2.0 - 64, 0.0 - 128) 
	fruits.add_child(f)
	fruit_connect(f)
	


func _on_reset_button_pressed() -> void:
	# start_fruit.reset()
	Global.to_main()


func _on_bounds_body_entered(body: Node2D) -> void:
	print("body out of bounds, ", body)
	body.call_deferred("queue_free")
