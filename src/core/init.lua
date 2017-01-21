dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
cowPool = ObjectPooler(3, 5, 2, GenerateCow)
platformPool = ObjectPooler(1, 5, 2, GeneratePlatform)
math.randomseed(os.time())

-- add init stuff below