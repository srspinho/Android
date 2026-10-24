extends Area2D
## Projétil do jogador (ciano) ou dos inimigos (laranja).

var main
var direction := Vector2.RIGHT
var speed := 330.0
var from_player := true

var _life := 1.2


func _ready() -> void:
	collision_layer = 0
	# Camadas: 1 = cenário, 2 = jogador, 4 = inimigos.
	collision_mask = 1 | (4 if from_player else 2)
	if not from_player:
		speed = 170.0
		_life = 2.5
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(6, 3)
	cs.shape = shape
	cs.rotation = direction.angle()
	add_child(cs)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("hurt"):
		body.hurt(1)
	main.spawn_fx(global_position, _color(), 6.0)
	queue_free()


func _color() -> Color:
	return Color("#00f0ff") if from_player else Color("#ff7a1a")


func _draw() -> void:
	var c := _color()
	var tail := -direction * 9.0
	draw_line(tail, Vector2.ZERO, Color(c, 0.3), 4.0)
	draw_line(tail * 0.6, Vector2.ZERO, c, 2.0)
	draw_circle(Vector2.ZERO, 1.5, Color.WHITE)
