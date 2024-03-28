--[[
    GD50
    Match-3 Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Match-3 has taken several forms over the years, with its roots in games
    like Tetris in the 80s. Bejeweled, in 2001, is probably the most recognized
    version of this game, as well as Candy Crush from 2012, though all these
    games owe Shariki, a DOS game from 1994, for their inspiration.

    The goal of the game is to match any three tiles of the same variety by
    swapping any two adjacent tiles; when three or more tiles match in a line,
    those tiles add to the player's score and are removed from play, with new
    tiles coming from the ceiling to replace them.

    As per previous projects, we'll be adopting a retro, NES-quality aesthetic.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch

    Credit for music (awesome track):
    http://freemusicarchive.org/music/RoccoW/

    Cool texture generator, used for background:
    http://cpetry.github.io/TextureGenerator-Online/
]]

-- initialize our nearest-neighbor filter
love.graphics.setDefaultFilter('nearest', 'nearest')

-- this time, we're keeping all requires and assets in our Dependencies.lua file
require 'src/Dependencies'

-- physical screen dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual resolution dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- speed at which our background texture will scroll
BACKGROUND_SCROLL_SPEED = 80

-- colors we'll use to change the title text
G_COLORS = {
    [1] = {217/255, 87/255, 99/255, 1},
    [2] = {95/255, 205/255, 228/255, 1},
    [3] = {251/255, 242/255, 54/255, 1},
    [4] = {118/255, 66/255, 138/255, 1},
    [5] = {153/255, 229/255, 80/255, 1},
    [6] = {223/255, 113/255, 38/255, 1}
}

function love.load()
    
    -- window bar title
    love.window.setTitle('Match 3')

    -- seed the RNG
    math.randomseed(os.time())

    -- initialize our virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    -- set music to loop and start
    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- keep track of scrolling our background on the X axis
    backgroundX = 0

    local shader_code = [[
        extern float iTime;
        
        vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords)
        {
            vec4 pixel = Texel(image, uvs);           
            vec4 col = vec4(vec3(color), 0.5);        
            vec2 uv = uvs;
            for(int c=0;c<3;c++){
                float scale = 5.5;
                float scale1 = 1.4;
                float s1 = scale1*scale;
                for(int i=0;i<6;i++)
                {
                    uv += uv.yy;
                    uv = fract((uv+iTime)/s1)*s1;
                    uv=-fract(uv/(3.0-abs((uv.x-uv.y)/(16.0)))-(uv/(2.5+(fract(uv.x+uv.y))))/scale)*scale/scale1+s1;
                    uv /= scale1+col.yx;
                    uv=uv.yx+col.xy;
                    uv.x *= -(1.0+col.x/scale);
                    col[c] = fract((((1.0+col.y)*.125)*(col.x+uv.y-uv.x))/2.25);
                }
            }
            color = vec4(vec3(col),1.0);
            
            return pixel * color;
        }
    ]]

    shinyShader = love.graphics.newShader(shader_code)

    -- initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    
    -- scroll background, used across all states
    backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt
    
    -- if we've scrolled the entire image, reset it to 0
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end

    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()

    -- scrolling background drawn behind every state
    love.graphics.draw(gTextures['background'], backgroundX, 0)
    
    gStateMachine:render()
    push:finish()
end