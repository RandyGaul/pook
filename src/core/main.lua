dofile("src/util/fileloader.lua")

loadfiles()

if KeyPressed( 'a' ) then
	print( "asdfasdf" )
end

PushInstance( "simple", "triangle", 0, 0, 0)

Flush( "simple" )
