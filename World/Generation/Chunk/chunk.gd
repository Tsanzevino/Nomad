class_name Chunk extends MeshInstance3D

static var size : int = 64

static func get_chunk_coordinates(x : float, z : float) -> Vector2i:
	return Vector2i(roundi(x / Chunk.size), roundi(z / Chunk.size))
