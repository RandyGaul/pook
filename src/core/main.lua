dofile("src/util/fileloader.lua")

if KeyPressed( 'a' ) then
	print( "asdfasdf" )
end

for i, v in pairs(world) do
	v:Render()
	v:Update()
end

-- Flush( "simple" )
-- Flush( "quads" )
