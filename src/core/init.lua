dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
math.randomseed(os.time())

cowPool = ObjectPooler(4, 5, 2, GenerateCow)
platformPool = ObjectPooler(4, 5, 2, GeneratePlatform)
player = GeneratePlayer()

-- add init stuff below