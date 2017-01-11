if KeyPressed( 'a' ) then
	print( "asdfasdf" )
end

for i = 0, 3 do
	PushInstance( "simple", "triangle", i * s( dt * 2 ) * 0.5, i * c( dt ), i * s( dt ) )
end
Flush( "simple" )
