extends HSlider

@export var bus_name: String
var bus_index: int

func _ready() -> void:
	# get index of audio bus with specified name
	bus_index = AudioServer.get_bus_index(bus_name)
	# connect value_changed signal of the slider
	value_changed.connect(_on_value_changed)
	# set the initial value of the slider from the current bus value
	_set_slider_value_from_bus()


# set the initial value of the slider from the current bus value
func _set_slider_value_from_bus() -> void:
	# get current value of the bus,
	# and convert to linear slider range of 0 to 1, to set the initial value of the slider.
	value = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)


# update the audio bus whenever the slider is changed
func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(new_value)
	)
	Global.save_data.bus_volume[bus_name] = new_value
	Global.save_data.save()
