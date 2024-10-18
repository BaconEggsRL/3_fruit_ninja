extends Node2D


func _ready() -> void:
	# Set the current scene
	Global.current_scene = self
	
#func _process(delta: float) -> void:
	#pass


func _on_start_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_game()


func _on_scores_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_scores()


func _on_credits_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_credits()


func _on_settings_button_pressed() -> void:
	Global.play_sound("button")
	Global.to_settings()
