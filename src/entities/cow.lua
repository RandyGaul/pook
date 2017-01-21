function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/coin.obj")
	cow.pos = v3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))

	cow.GenerateMesh = function(self)
		if GeneratedMeshes["cow"] ~= nil then
			return
		end

		PushMeshLua(self.verts.triangleVerts, "triangle")
		PushMeshLua(self.verts.quadVerts, "quad")
		GeneratedMeshes["cow"] = true
	end

	cow.Render = function(self)
		PushInstance( "simple", "triangle", cow.pos.x, cow.pos.y, cow.pos.z, .5, .5, .5)
		PushInstance( "quads", "quad", cow.pos.x, cow.pos.y, cow.pos.z, .5, .5, .5)
	end

	cow.Update = function(self) end

	return cow
end