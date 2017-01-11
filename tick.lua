dofile( "input.lua" )

s = math.sin
c = math.cos
dt = 0

function PushVert( x, y, z, cx, cy, cz, nx, ny, nz )
	cx = cx or 1; cy = cy or 1; cz = cz or 1
	nx = nx or 0; ny = ny or 1; nz = nz or 0
	PushVert_internal( x, y, z, cx, cy, cz, nx, ny, nz )
end

function MakeMeshes( )
	PushVert( 0, 1, 0, 0.1, 0.4, 0.8 )
	PushVert( -1, -1, 0, 0.5, 0.2, 0.4 )
	PushVert( 1, -1, 0, 0.25, 0.1, 0.2 )
	PushMesh( "triangle" )
end

function Tick( dt_param )
	dt = dt + dt_param
	dofile( "main.lua" )
	PromoteKeys( )
end
