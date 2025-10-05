class_name ItemSpawner extends Node



func spawn(item : Item, amount : int, mesh : MeshInstance3D = null):
	var c = TimedCollectable.new()
	c.countFunction = func(): return amount
	c.item = item
	owner.owner.add_child(c)
	c.global_position = owner.global_position
	if mesh != null:
		c.add_child(mesh)
		mesh.create_trimesh_collision()
		mesh.get_child(0).get_child(0).reparent(c)
		mesh.get_child(0).queue_free()
	else:
		mesh = MeshInstance3D.new()
		mesh.mesh = SphereMesh.new()
		mesh.mesh.radius = .1
		mesh.mesh.height = .2
		c.add_child(mesh)
		var collision : CollisionShape3D = CollisionShape3D.new()
		collision.shape = SphereShape3D.new()
		collision.shape.radius = 0.1
		c.add_child(collision)
