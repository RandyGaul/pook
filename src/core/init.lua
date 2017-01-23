dofile("src/util/fileloader.lua")

-- globals
s = math.sin
c = math.cos
world = {}
math.randomseed(os.time())
GRAVITY = 150

THE_COINS = {}
THE_COIN_ID = 0
NUM_REMAINING_COINS = 15

THE_BOXES = {}
THE_BOXES_ID = 0

function JumpHeight( height )
    return math.sqrt( 2 * GRAVITY * height )
end

ClearCubes();

cowPool = ObjectPooler(NUM_REMAINING_COINS, 50, 2, GenerateCow)
platformPool = ObjectPooler(33, 50, 2, GeneratePlatform)
player = GeneratePlayer()

skybox = GenerateSkybox()
GenerateLevel(30)
sharkPool = ObjectPooler(6, 6, 2, GenerateShark)