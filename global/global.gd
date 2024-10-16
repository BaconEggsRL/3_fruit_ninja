extends Node

# Loading scenes
var current_scene = null

#const game_scene_path : String = "res://game.tscn"
const main_scene_path : String = "res://main.tscn"
#const scores_scene_path : String = "res://scores.tscn"
#
#var game_scene : PackedScene = preload(game_scene_path)
var main_scene : PackedScene = preload(main_scene_path)
#var scores_scene : PackedScene = preload(scores_scene_path)
#
#const credits_scene_path : String = "res://credits.tscn"
#var credits_scene : PackedScene = preload(credits_scene_path)



var save_data:SaveData


# Game settings
var is_game_paused = false
var is_game_over = false

@onready var sounds = $sounds

const SCROLL_SPEED = 200.0
const PIPE_TIME = 1.40
const JUMP_VEL = -400.0


@onready var swipe: AudioStreamPlayer = $sounds/swipe

var mobile = false




# Both the current scene (the one with the button) and global.gd 
# are children of root, but autoloaded nodes are always first. 
# This means that the last child of root is always the loaded scene.
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	save_data = SaveData.load_or_create()
	
	# get OS
	print("OS name = ", OS.get_name())
	if OS.has_feature("mobile"):
		mobile = true
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		mobile = true
	print("mobile = ", mobile)



# Audio Manager
######################################################################
#func queue_sound(path) -> void:
	#var sound : AudioStreamPlayer = get_node(path)
	#if is_any_sound_playing():
		#
		#
		
func play_sound(path, wait=true) -> void:
	var sound : AudioStreamPlayer = sounds.get_node(path)
	if wait:
		if not sound.playing:
			sound.play()
	else:
		sound.play()

func play_swipe() -> void:
	if not swipe.playing:
		var pitch = randf_range(1.5, 3)
		
		swipe.pitch_scale = pitch
		print("before play pitch_scale = ", swipe.pitch_scale)
		
		swipe.play()
		
		print("after play pitch_scale = ", swipe.pitch_scale)
		swipe.pitch_scale = pitch

# Scene Manager
######################################################################
#func to_game() -> void:
	#goto_scene(game_scene)
	#
func to_main() -> void:
	goto_scene(main_scene)

#func to_scores() -> void:
	#goto_scene(scores_scene)
#
#func to_credits() -> void:
	#goto_scene(credits_scene)



func goto_scene(path) -> void:
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)


func _deferred_goto_scene(path) -> void:

	# Use string or packed scene
	assert (path is String or path is PackedScene)
	
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s
	if path is String:
		s = ResourceLoader.load(path)
	if path is PackedScene:
		s = path
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
