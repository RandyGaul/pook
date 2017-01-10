function PushVert( x, y, z, cx, cy, cz, nx, ny, nz )
	cx = cx or 1; cy = cy or 1; cz = cz or 1
	nx = nx or 0; ny = ny or 1; nz = nz or 0
	PushVert_internal( x, y, z, cx, cy, cz, nx, ny, nz )
end

init = false

function Tick( dt )
	print( "called Tick" )
	print( "dt was", dt )
	
	if not init then
		init = true
		PushVert( 0, 1, 0, 0.1, 0.4, 0.8 )
		PushVert( -1, -1, 0, 0.1, 0.4, 0.8 )
		PushVert( 1, -1, 0, 0.1, 0.4, 0.8 )
		PushMesh( "triangle" )
	end
	
	SetRender( "simple" )
	for i = 0, 3 do
		PushInstance( "triange", 0, i * 5, 0 )
	end
	Flush( )
end
