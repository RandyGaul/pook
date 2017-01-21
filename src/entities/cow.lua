function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/bb8.obj")
	cow.x = math.random(-5, 5)
	cow.y = math.random(-5, 5)
	cow.z = math.random(-5, 5)

	cow.generateMesh = function(self)
		GenerateMesh(self.verts.triangleVerts, "triangle")
		GenerateMesh(self.verts.quadVerts, "quad")
	end

	cow.render = function(self)
		PushInstance( "simple", "triangle", cow.x, cow.y, cow.z)
		PushInstance( "quads", "quad", cow.x, cow.y, cow.z)
	end

	cow.update = function(self) end

	return cow
end