local function GenerateMesh()
	local A, B, C, D, E, F, G, H =
		{-1, 1, 1}, 	--A
		{1, 1, 1},  	--B
		{1, -1, 1}, 	--C
		{-1, -1, 1},	--D
		{-1, 1, -1},	--E
		{1, 1, -1}, 	--F
		{-1, -1, -1},	--G
		{1, -1, -1}		--H

	PushMeshLua({C,A,B,C,D,A,H,D,C,H,G,D,H,F,G,G,F,E,B,E,
		F,B,A,E,D,E,A,D,G,E,F,C,B,H,C,F}, "skybox")
end

local function Render(self)
	PushInstance("simple", "skybox", 0, 0, 0, self.s.x, self.s.y, self.s.z)
end

function GenerateSkybox()
	local skybox = {}
	skybox.GenerateMesh = GenerateMesh
	skybox.s = v3(500, 500, 500)
	skybox.Render = Render
	skybox.Update = function() end

	table.insert(world, skybox)
end
