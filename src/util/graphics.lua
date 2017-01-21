if GeneratedMeshes == nil then
	GeneratedMeshes = {}
end

function PushInstance( mesh_name, shader_name, x, y, z, sx, sy, sz, rx, ry, rz, ra )
	x = x or 0; y = y or 0; z = z or 0;
	sx = sx or 1; sy = sy or 1; sz = sz or 1;
	rx = rx or 0; ry = ry or 1; rz = rz or 0;
	ra = ra or 0
	PushInstance_internal( mesh_name, shader_name, x, y, z, sx, sy, sz, rx, ry, rz, ra )
end

function PushVert( x, y, z, cx, cy, cz, nx, ny, nz )
	cx = cx or 1; cy = cy or 1; cz = cz or 1
	nx = nx or 0; ny = ny or 1; nz = nz or 0
	PushVert_internal( x, y, z, cx, cy, cz, nx, ny, nz )
end

function MakeMeshes( )
	for i, v in pairs(world) do
		v:GenerateMesh()
	end
end

function PushMeshLua(verts, name)
	for i, j in ipairs(verts) do
		if i % 3 == 0 then
			PushVert(j[1], j[2], j[3], 1, 0.4, 0.8)
		elseif i % 3 == 1 then
			PushVert(j[1], j[2], j[3], 0.5, 1, 0.4)
		elseif i % 3 == 2 then
			PushVert(j[1], j[2], j[3], 0.25, 0.1, 1)
		else
			PushVert(j[1], j[2], j[3], 1, .25, 0)
		end
	end

	PushMesh(name)
end
