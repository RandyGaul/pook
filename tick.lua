dofile( "input.lua" )
local ObjLoader = require("parser")

s = math.sin
c = math.cos
dt = 0
t = 0

function PushVert( x, y, z, cx, cy, cz, nx, ny, nz )
	cx = cx or 1; cy = cy or 1; cz = cz or 1
	nx = nx or 0; ny = ny or 1; nz = nz or 0
	PushVert_internal( x, y, z, cx, cy, cz, nx, ny, nz )
end

function MakeMeshes( )
	local cowVerts = ObjLoader.getVerts("models/cow.obj")
	GenerateTriangleMesh(cowVerts.triangleVerts)
end

function GenerateTriangleMesh(triangleVerts)
	for i, j in ipairs(triangleVerts) do
		if i % 3 == 0 then
			PushVert(j[1], j[2], j[3], 1, 0.4, 0.8)
		end
		if i % 3 == 1 then
			PushVert(j[1], j[2], j[3], 0.5, 1, 0.4)
		end
		if i % 3 == 2 then
			PushVert(j[1], j[2], j[3], 0.25, 0.1, 1)
		end
	end
	PushMesh("triangle")
end

function Tick( dt_param )
	dt = dt_param
	t = math.fmod( t + dt_param, 3.14159265359 * 2 )
	dofile( "main.lua" )
	PromoteKeys( )
end
