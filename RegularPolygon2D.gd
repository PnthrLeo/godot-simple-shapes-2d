@tool
extends Node2D


@export_range(3, 100) var vertices_num: int = 3: \
	set = set_vertices_num, get = get_vertices_num
@export var polygon_radius: float = 64.0: \
	set = set_polygon_radius, get = get_polygon_radius
@export_range(-360.0, 360.0) var polygon_rotation: float: \
	set = set_polygon_rotation, get = get_polygon_rotation
@export var polygon_color: Color = \
	Color(36.0/256.0, 138.0/256.0, 199.0/256.0): \
	set = set_polygon_color, get = get_polygon_color
@export var polygon_texture: Texture: \
	set = set_polygon_texture, get = get_polygon_texture
@export var border_size: float = 4.0: \
	set = set_border_size, get = get_border_size
@export var border_color: Color = Color(0.0, 0.0, 0.0): \
	set = set_border_color, get = get_border_color
@export var is_auto_collision_shape: bool = true: \
	set = set_is_auto_collision_shape, get = get_is_auto_collision_shape


func cacl_vertices_pos(radius: float) -> PackedVector2Array:
	var angle_gap: float = 2 * PI / vertices_num
	var vertices_pos: PackedVector2Array = PackedVector2Array()
	for i in range(vertices_num):	
		vertices_pos.append(Vector2(radius, 0).rotated( 
			deg_to_rad(-90+polygon_rotation) + i*angle_gap))
	return vertices_pos

func draw_poly(radius: float, color: Color, texture: Texture) -> void:
	var points: PackedVector2Array = cacl_vertices_pos(radius)

	var uvs: PackedVector2Array = PackedVector2Array()	
	if polygon_texture:
		var ts: Vector2 = polygon_texture.get_size()
		for pt in points:
			uvs.append((pt / radius / 2.0).rotated(
				-deg_to_rad(polygon_rotation)) + Vector2(0.5, 0.5))

	draw_colored_polygon(points, color, uvs, texture)

func _draw() -> void:
	if border_size > 0:
		draw_poly(polygon_radius, border_color, null)
	draw_poly(polygon_radius - border_size, polygon_color, polygon_texture)

func setup_collision_shape() -> void:
	var parent_node: Node = get_parent();
	if is_auto_collision_shape and parent_node is CollisionObject2D:
		var shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()
		shape.points = cacl_vertices_pos(polygon_radius)
		
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		collision_shape.shape = shape
		parent_node.call_deferred("add_child", collision_shape)

func remove_collision_shape(force: bool = false) -> void:
	var parent_node: Node = get_parent();
	if (is_auto_collision_shape || force) and parent_node is CollisionObject2D:
		var collision_shape = parent_node.get_node("CollisionShape2D")
		parent_node.call_deferred("remove_child", collision_shape)

func _enter_tree() -> void:
	setup_collision_shape()

func _exit_tree() -> void:
	remove_collision_shape()

func update_collision_shape() -> void:
	remove_collision_shape()
	setup_collision_shape()

func set_vertices_num(value: int) -> void:
	vertices_num = value
	vertices_num = clamp(vertices_num, 3, INF)
	queue_redraw()
	update_collision_shape()

func get_vertices_num() -> int:
	return vertices_num

func set_polygon_radius(value: float) -> void:
	polygon_radius = value
	polygon_radius = clamp(polygon_radius, 0, INF)
	
	if polygon_radius < border_size:
		set_border_size(polygon_radius)
	
	queue_redraw()
	update_collision_shape()

func get_polygon_radius() -> float:
	return polygon_radius

func set_polygon_rotation(angle: float) -> void:
	polygon_rotation = angle
	queue_redraw()
	update_collision_shape()

func get_polygon_rotation() -> float:
	return polygon_rotation

func get_border_color() -> Color:
	return border_color

func set_polygon_color(color: Color) -> void:
	polygon_color = color
	queue_redraw()

func set_polygon_texture(texture: Texture) -> void:
	polygon_texture = texture
	queue_redraw()

func get_polygon_texture() -> Texture:
	return polygon_texture

func set_border_size(size: float) -> void:
	border_size = size
	border_size = clamp(border_size, 0.0, polygon_radius)	
	queue_redraw()

func get_border_size() -> float:
	return border_size

func set_border_color(color: Color) -> void:
	border_color = color
	queue_redraw()

func get_polygon_color() -> Color:
	return polygon_color

func set_is_auto_collision_shape(value: bool) -> void:
	is_auto_collision_shape = value
	
	if not is_auto_collision_shape:
		remove_collision_shape(true)
	else:
		setup_collision_shape()

func get_is_auto_collision_shape() -> bool:
	return is_auto_collision_shape
