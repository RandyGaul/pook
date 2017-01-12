if KeyPressed( 'a' ) then
	print( "asdfasdf" )
end

for i = 0, 3 do
	PushInstance( "simple", "triangle", i * s( t * 2 ) * 0.5, i * c( t ), i * s( t ) )
end
Flush( "simple" )
