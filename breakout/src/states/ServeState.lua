--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    
    self.ballsArray = {}

    if (params.nextPowerUp == nil) then    
        self.powerUp_Timer = 0
        self.nextPowerUp = 5
    else
        self.powerUp_Timer = params.powerUp_Timer
        self.nextPowerUp = params.nextPowerUp
    end

    ServeState:addBall(self)    
end

function ServeState:update(dt)
    -- have the ball track the player
    self.paddle:update(dt)

    for i, iBall in ipairs(self.ballsArray) do

        iBall.x = self.paddle.x + (self.paddle.width / 2) - 4
        iBall.y = self.paddle.y - 8

    end    

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            ball = self.ball,
            level = self.level,
            recoverPoints = self.recoverPoints,
            ballsArray = self.ballsArray,
            powerUp_Timer = self.powerUp_Timer,
            nextPowerUp = self.nextPowerUp
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()

    for i, iBall in ipairs(self.ballsArray) do
        if (iBall) then 
            iBall:render()
        end
    end    

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end

function ServeState:addBall(_state) 

    -- store position for new ball
    i = table.getn(_state.ballsArray)+1

    -- init new ball (random color for fun)
    _state.ballsArray[i] = Ball()    
    _state.ballsArray[i].skin = math.random(7)
    _state.ballsArray[i]:reset()

    -- set ball to paddle location
    _state.ballsArray[i].x = _state.paddle.x + (_state.paddle.width / 2) - 4
    _state.ballsArray[i].y = _state.paddle.y - 8

    --set random velocity for ball
    _state.ballsArray[i].dx = math.random(-200, 200)
    _state.ballsArray[i].dy = math.random(-50, -60)
end

