dofile("src/util/fileloader.lua")

if KeyPressed( 'a' ) then
	print( "asdfasdf" )
end

for i, v in pairs(world) do
	v:render()
	v:update()
end

Flush( "simple" )
