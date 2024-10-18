extends Node2D

@export var best_score : Label

@onready var audio_popup: ConfirmationDialog = $AudioPopup
@onready var score_popup: ConfirmationDialog = $ScorePopup

@export var music : RichTextLabel
@export var code : RichTextLabel

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
		"Master": 1,
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
