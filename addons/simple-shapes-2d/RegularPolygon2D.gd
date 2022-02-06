# Refactored version of code from: https://github.com/RoboYorkie/Godot_RegularPolygon2D/blob/master/addons/regular_polygon2d_node/RegularPolygon2D.gd
# TODO: Redo texture addition
tool
extends Node2D


export(int, 3, 100) var vertices_num = 3 setget set_vertices_num, get_vertices_num
export(float) var polygon_radius = 64.0 setget set_polygon_radius, get_polygon_radius
export(Color) var polygon_color = Color(36.0/256.0, 138.0/256.0, 199.0/256.0) setget set_polygon_color, get_polygon_color
export(Texture) var polygon_texture setget set_polygon_texture, get_polygon_texture

export(float) var border_size = 4.0 setget set_border_size, get_border_size
export(Color) var border_color = Color(0.0, 0.0, 0.0) setget set_border_color, get_border_color

export(float, -360.0, 360.0) var polygon_rotation setget set_polygon_rotation, get_polygon_rotation

# Configure a collision shape if the parent is a CollisionObject2D.
# e.g. KinematicBody2D, RigidyBody2D, Area2D, or StaticBody2D
export(bool) var is_physical = true setget set_is_physical, get_is_physical


func cacl_vertices_pos(radius: float) -> PoolVector2Array:
	var angle_gap: float = 2 * PI / vertices_num
	var vertices_pos: PoolVector2Array = PoolVector2Array()
	for i in range(vertices_num):	
		vertices_pos.append(polar2cartesian(radius, 
											deg2rad(-90+polygon_rotation) + i*angle_gap))
	return vertices_pos

func draw_poly(radius: float, color: Color, texture: Texture) -> void:
	var points: PoolVector2Array = cacl_vertices_pos(radius)

	var uvs: PoolVector2Array = PoolVector2Array()	
	if polygon_texture:
		var ts: Vector2 = polygon_texture.get_size()
		for pt in points:
			uvs.append((pt + Vector2(radius, radius)) / ts)

	draw_colored_polygon(points, color, uvs, texture, polygon_texture, true)

func _draw() -> void:
	if border_size > 0:
		draw_poly(polygon_radius + border_size, border_color, null)
	draw_poly(polygon_radius, polygon_color, polygon_texture)

func _ready() -> void:
	if !is_physical || Engine.is_editor_hint():
		return
		
	var parent_node: Node = get_parent();
	if parent_node == null:
		return
	
	if parent_node is CollisionObject2D:
		var shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()
		shape.points = cacl_vertices_pos(polygon_radius + border_size)
		var collision_shape: CollisionShape2D = CollisionShape2D.new()
		collision_shape.shape = shape
		parent_node.call_deferred("add_child", collision_shape)

func set_is_physical(value: bool) -> void:
	is_physical = value

func get_is_physical() -> bool:
	return is_physical

func set_polygon_texture(texture: Texture) -> void:
	polygon_texture = texture
	update()

func get_polygon_texture() -> Texture:
	return polygon_texture

func set_border_color(color: Color) -> void:
	border_color = color
	update()

func get_border_color() -> Color:
	return border_color

func set_polygon_color(color: Color) -> void:
	polygon_color = color
	update()

func get_polygon_color() -> Color:
	return polygon_color

func set_polygon_rotation(angle: float) -> void:
	polygon_rotation = angle
	update()

func get_polygon_rotation() -> float:
	return polygon_rotation

func set_border_size(size: float) -> void:
	border_size = size
	update()

func get_border_size() -> float:
	return border_size

func set_vertices_num(value: int) -> void:
	vertices_num = value
	update()

func get_vertices_num() -> int:
	return vertices_num

func set_polygon_radius(value: float) -> void:
	polygon_radius = value
	update()

func get_polygon_radius() -> float:
	return polygon_radius
