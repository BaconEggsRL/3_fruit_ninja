extends Node

# Loading scenes
var current_scene = null

const arcade_scene_path : String = "res://scenes/game.tscn"
const classic_scene_path : String = "res://scenes/game_classic.tscn"
const main_scene_path : String = "res://scenes/main.tscn"
const scores_scene_path : String = "res://scenes/scores.tscn"
const credits_scene_path : String = "res://scenes/credits.tscn"
const settings_scene_path : String = "res://scenes/settings.tscn"

var arcade_scene : PackedScene = preload(arcade_scene_path)
var classic_scene : PackedScene = preload(classic_scene_path)
var main_scene : PackedScene = preload(main_scene_path)
var scores_scene : PackedScene = preload(scores_scene_path)
var credits_scene : PackedScene = preload(credits_scene_path)
var settings_scene : PackedScene = preload(settings_scene_path)


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


const POPO = preload("res://sounds/popo.mp3")
const FRUIT_SLICES__VOCAL_2_ = preload("res://sounds/Fruit Slices (Vocal_2).mp3")
const FRUIT_SLICE_SERENADE__INSTRUMENTAL_ = preload("res://sounds/Fruit Slice Serenade (Instrumental).mp3")
# music arranged according to indices in settings dropdown
var music_arr = [POPO, FRUIT_SLICES__VOCAL_2_, FRUIT_SLICE_SERENADE__INSTRUMENTAL_]

@onready var music: AudioStreamPlayer = $sounds/music



# Both the current scene (the one with the button) and global.gd 
# are children of root, but autoloaded nodes are always first. 
# This means that the last child of root is always the loaded scene.
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	
	save_data = SaveData.load_or_create()
	
	# set default music
	music.stream = music_arr[save_data.music_index]
	# set bus volume
	set_bus_volume()
	# play music
	music.play()
	
	# get OS
	print("OS name = ", OS.get_name())
	if OS.has_feature("mobile"):
		mobile = true
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		mobile = true
	print("mobile = ", mobile)


# Functions
######################################################################


# set volume of each bus from save data
func set_bus_volume() -> void:
	for bus_name in save_data.bus_volume:
		var bus_index = AudioServer.get_bus_index(bus_name)
		var value = save_data.bus_volume[bus_name]
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(value)
		)



# Audio Manager
######################################################################

# fade current music to new music index
func music_fade_to(
	index:int=0, 
	fade_out_time:float=1.0, 
	start_delay:float=1.0, 
	fade_in_time:float=0.0) -> void:
		
	assert(start_delay>=0.0 and fade_in_time>=0.0)
	assert(index >= 0 and index <= music_arr.size()-1)
	
	print("music IDX = ", index)
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(music, "volume_db", -80, fade_out_time)
	fade_out_tween.connect(
		"finished", 
		_on_fade_out_tween_finished.bind(index, start_delay, fade_in_time)
		)


# start new song once old one is finished
func _on_fade_out_tween_finished(
	index:int=0,
	start_delay:float=1.0, 
	fade_in_time:float=0.0) -> void:
		
	if start_delay > 0:
		var start_music_timer = Timer.new()
		start_music_timer.one_shot = true
		start_music_timer.wait_time = start_delay
		self.call_deferred("add_child", start_music_timer)
		start_music_timer.timeout.connect(
			_on_start_music_timer_timeout.bind(index, start_music_timer, fade_in_time)
			)
		start_music_timer.call_deferred("start")
	else:
		_on_start_music_timer_timeout(index, null, fade_in_time)
		


# start new song after a delay
func _on_start_music_timer_timeout(
	index:int = 0, 
	start_music_timer=null, 
	fade_in_time:float = 0.0) -> void:
	
	# stop music and re-assign song
	music.stop()
	music.stream = music_arr[index]
	print("music IDX = ", index)
	
	# create fade in tween
	var fade_in_tween = create_tween()
	fade_in_tween.tween_property(music, "volume_db", 0, fade_in_time)
	
	# restart music
	music.play()
	
	# delete timer
	if start_music_timer != null:
		start_music_timer.call_deferred("queue_free")



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
		# print("before play pitch_scale = ", swipe.pitch_scale)
		
		swipe.play()
		
		# print("after play pitch_scale = ", swipe.pitch_scale)
		swipe.pitch_scale = pitch

# Scene Manager
######################################################################
func to_arcade() -> void:
	goto_scene(arcade_scene)

func to_classic() -> void:
	goto_scene(classic_scene)
	
func to_main() -> void:
	goto_scene(main_scene)

func to_scores() -> void:
	goto_scene(scores_scene)

func to_credits() -> void:
	goto_scene(credits_scene)

func to_settings() -> void:
	goto_scene(settings_scene)
	
	

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
