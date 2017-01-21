function Tick( dt_param )
	dt = dt_param or 0
	t = t or 0
	t = t + dt_param
	dofile( "src/core/main.lua" )
	PromoteKeys( )
end