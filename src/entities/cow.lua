function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/cow.obj")
	cow.x = math.random(-5, 5)
	cow.y = math.random(-5, 5)
	cow.z = math.random(-5, 5)

	cow.generateMesh = function(self)
		GenerateTriangleMesh(self.verts.triangleVerts)
	end

	cow.render = function(self)
		PushInstance( "simple", "triangle", cow.x, cow.y, cow.z)
	end

	cow.update = function(self) end

	return cow
end