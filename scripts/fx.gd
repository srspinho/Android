extends Node2D
## Faísca/explosão rápida que some sozinha.

const DURATION := 0.35

var color := Color.WHITE
var size := 10.0

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	if _t >= DURATION:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var k := _t / DURATION
	var fade := 1.0 - k
	draw_arc(Vector2.ZERO, size * (0.3 + k), 0.0, TAU, 20, Color(color, fade), 2.0)
	draw_circle(Vector2.ZERO, size * 0.4 * fade, Color(1, 1, 1, fade))
	for i in 8:
		var p := Vector2.from_angle(i * TAU / 8.0 + size) * size * (0.4 + k * 1.2)
		draw_rect(Rect2(p - Vector2.ONE, Vector2(2, 2)), Color(color, fade))
