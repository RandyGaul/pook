dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
cowPool = ObjectPooler(3, 5, 2, GenerateCow)

-- add init stuff below