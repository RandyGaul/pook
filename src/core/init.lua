dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
math.randomseed(os.time())

cowPool = ObjectPooler(15, 20, 2, GenerateCow)
platformPool = ObjectPooler(15, 5, 2, GeneratePlatform)
player = GeneratePlayer()
--skybox = GenerateSkybox()
GenerateLevel(5)

-- add init stuff below