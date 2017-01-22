COIN_SPIN_SPEED = math.pi * 2 * 0.1

function GenerateCow()
	local cow = {}
	cow.verts = ObjLoader.getVerts("assets/models/coin.obj")
	print("there are "..#cow.verts.." cow verts")
	cow.p = v3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
	cow.spinAngle = 0
	cow.alive = true

	cow.id = THE_COIN_ID
	THE_COIN_ID = THE_COIN_ID + 1
	THE_COINS[ cow.id ] = cow

	cow.GenerateMesh = function(self)
		if GeneratedMeshes["cow"] ~= nil then
			return
		end

		PushMeshLua(self.verts, "triangle", {1, 1, 0})

		GeneratedMeshes["cow"] = true
	end

	cow.Render = function(self)
		if not self.alive then return end
		local angle = self.spinAngle
		local rx = 0
		local ry = 1
		local rz = 0
		PushInstance( "simple", "triangle", self.p.x, self.p.y, self.p.z, .5, .5, .5, rx, ry, rz, angle)
	end

	cow.Update = function(self)
		self.spinAngle = self.spinAngle + COIN_SPIN_SPEED * dt
	end

	return cow
end
