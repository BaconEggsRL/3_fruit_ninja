class_name SaveData extends Resource

@export var sandbox_high_score:int = 0
@export var classic_high_score:int = 0
@export var bomb_slider_value:float = 0.0

@export var music_index:int = 0

@export var num_bots:int = 2


@export var bus_volume: Dictionary = {
	"Master": 0.5,
	"music": 1,
	"sfx": 1,
}



const SAVE_PATH:String = "user://save_data.tres"


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)
	
	
func clear() -> void:
	self.sandbox_high_score = 0
	self.classic_high_score = 0
	self.bomb_slider_value = 0.0
	self.music_index = 0
	self.num_bots = 2
	
	self.bus_volume = {
		"Master": 0.5,
		"music": 1,
		"sfx": 1,
	}

	save()
	
	
static func load_or_create() -> SaveData:
	var res:SaveData
	if FileAccess.file_exists(SAVE_PATH):
		res = load(SAVE_PATH) as SaveData
	else:
		res = SaveData.new()
	return res
