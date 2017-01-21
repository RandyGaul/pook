COIN_SPIN_SPEED = math.pi * 2

function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/coin.obj")
	cow.pos = v3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	cow.spinAngle = 0

	cow.GenerateMesh = function(self)
		if GeneratedMeshes["cow"] ~= nil then
			return
		end

		PushMeshLua(self.verts.triangleVerts, "triangle")
		PushMeshLua(self.verts.quadVerts, "quad")

		-- test code for rotation
		-- self.spinAngle = math.random() * 2 * math.pi
		-- self:Spin()

		GeneratedMeshes["cow"] = true
	end

	cow.Render = function(self)
		PushInstance( "simple", "triangle", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5)
		PushInstance( "quads", "quad", self.pos.x, self.pos.y, self.pos.z, .5, .5, .5)
	end

	cow.Update = function(self)
		-- self:Spin()
	end

	cow.Spin = function(self)
		self.spinAngle = self.spinAngle + COIN_SPIN_SPEED * dt

		local function spinFunc(verts, mesh)
			for i, v in pairs(verts) do
				local rotatedX = v[1] * math.cos(self.spinAngle) - v[3] * math.sin(self.spinAngle)
				local rotatedZ = v[1] * math.sin(self.spinAngle) + v[3] * math.cos(self.spinAngle)
				verts[i] = {rotatedX, v[2], rotatedZ}
			end
			PushMeshLua(verts, mesh)
		end

		spinFunc(self.verts.triangleVerts, "triangle")
		spinFunc(self.verts.quadVerts, "quad")
	end

	return cow
end