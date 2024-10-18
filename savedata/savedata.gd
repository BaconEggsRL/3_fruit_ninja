class_name SaveData extends Resource

@export var high_score:int = 0

@export var bus_volume: Dictionary = {
	"Master": 0.5,
	"music": 1,
	"sfx": 1,
}



const SAVE_PATH:String = "user://save_data.tres"


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)
	
	
func clear() -> void:
	self.high_score = 0
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
