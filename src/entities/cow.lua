function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/coin.obj")
	cow.pos = v3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))

	cow.generateMesh = function(self)
		GenerateMesh(self.verts.triangleVerts, "triangle")
		GenerateMesh(self.verts.quadVerts, "quad")
	end

	cow.render = function(self)
		PushInstance( "simple", "triangle", cow.pos.x, cow.pos.y, cow.pos.z)
		PushInstance( "quads", "quad", cow.pos.x, cow.pos.y, cow.pos.z)
	end

	cow.update = function(self) end

	return cow
end