extends RefCounted
## Shared phase boundaries and the existing final-hour quintic interpolation.
const NAMES: PackedStringArray = ["Morning", "Noon", "Afternoon", "Sunset", "Evening", "Night", "Dawn"]
const STARTS: PackedFloat32Array = [390, 720, 900, 1080, 1170, 1260, 300]

static func sample(minutes: float, starts: PackedFloat32Array = STARTS, transition_minutes: float = 60.0) -> Dictionary:
	var time: float = fposmod(minutes, 1440.0)
	for index in starts.size():
		var next: int = (index + 1) % starts.size()
		var duration: float = fposmod(starts[next] - starts[index], 1440.0)
		var elapsed: float = fposmod(time - starts[index], 1440.0)
		if duration <= 0.0 or elapsed >= duration:
			continue
		var length: float = maxf(0.001, minf(transition_minutes, duration))
		var t: float = clampf((elapsed - duration + length) / length, 0.0, 1.0)
		return {"index":index, "next":next, "name":NAMES[index], "weight":t*t*t*(t*(t*6.0-15.0)+10.0)}
	return {}
