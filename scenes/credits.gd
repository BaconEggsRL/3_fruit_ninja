extends Node2D


@export var music : RichTextLabel
@export var code : RichTextLabel


func _ready() -> void:
	# Set the current scene
	Global.current_scene = self
	music.meta_clicked.connect(_on_music_meta_clicked)
	code.meta_clicked.connect(_on_code_meta_clicked)
		

func _on_back_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_main()


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
