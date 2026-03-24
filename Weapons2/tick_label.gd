extends Label

var ticks_per_second := 0.0
var _tick_count := 0
var _time_accum := 0.0

const UPDATE_INTERVAL := 0.25

func _process(delta: float) -> void:
	_tick_count += 1
	_time_accum += delta

	if _time_accum >= UPDATE_INTERVAL:
		ticks_per_second = _tick_count / _time_accum
		_tick_count = 0
		_time_accum = 0.0
		text = "Ticks: %.1f" % ticks_per_second
