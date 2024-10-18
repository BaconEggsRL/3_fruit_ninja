extends Node2D

@export var best_score : Label

@onready var popup: ConfirmationDialog = $ConfirmationDialog


func _ready() -> void:
	# Set the current scene
	Global.current_scene = self
	
	popup.hide()
	best_score.text = "%s" % str(Global.save_data.high_score)


func _on_back_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_main()


func _on_erase_button_pressed() -> void:
	popup.show()


func _on_window_close_requested() -> void:
	popup.hide()


func _on_confirmation_dialog_confirmed() -> void:
	Global.save_data.clear()
	best_score.text = "%s" % str(Global.save_data.high_score)
