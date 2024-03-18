--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

local POWERUP_TIMER_MAX = 30
local POWERUP_TIMER_MIN = 10

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores    
    self.level = params.level    

    self.recoverPoints = 1000

    self.ball = params.ball

    self.ballsArray = params.ballsArray

    self.powerUp = nil
    self.powerUp_Timer = 0
    self.nextPowerUp = 5

    self.hasKey = false

    for i, iBall in ipairs(self.ballsArray) do
        --print (iBall)
    end

    for i, iBall in ipairs(self.ballsArray) do
       -- give ball random starting velocity
       iBall.dx = math.random(-200, 200)
       iBall.dy = math.random(-50, -60)
    end

end

function PlayState:update(dt)

    -- update timer for powerups
    self.powerUp_Timer = self.powerUp_Timer + dt

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)


    -- detect collision for balls
    for i, iBall in ipairs(self.ballsArray) do
        iBall:update(dt)

        if iBall:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            iBall.y = self.paddle.y - 8
            iBall.dy = -iBall.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if iBall.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                iBall.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - iBall.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif iBall.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                iBall.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - iBall.x))
            end
            gSounds['paddle-hit']:play()
        end
    end

    if self.powerUp_Timer > self.nextPowerUp then
                
        -- reset timer
        self.powerUp_Timer = 0
        
        -- add powerup
        self.powerUp = PowerUp()

        -- set nextPowerUp
        self.nextPowerUp = math.random() + math.random(POWERUP_TIMER_MIN, POWERUP_TIMER_MAX)

        print('Next PowerUp In: ', self.nextPowerUp)

    end
    

    -- keep all powerup UPDATE code inside an IF statement... we can't update a powerup that doesn't exist
    if (self.powerUp ~= nil)then
        self.powerUp:update(dt)

        -- if collides with paddle, check power type, take action
        if self.powerUp:collides(self.paddle) then

            self.x = 0
            self.y = 0

            if (self.powerUp.powerType == 3) then
                ServeState:addBall(self)
                ServeState:addBall(self)
            end

            if (self.powerUp.powerType == 4) then

                print('key collected!')

                self.hasKey = true
            end

            self.powerUp = nil
            
        else
            -- if powerup drops off the screen, kill
            if self.powerUp.y >= VIRTUAL_HEIGHT then
                self.powerUp = nil
            end
        end
    end
    
    -- detect collision across all bricks with and all balls...
    for k, brick in pairs(self.bricks) do

        for i, iBall in ipairs(self.ballsArray) do
            -- only check collision if we're in play
            if brick.inPlay and iBall:collides(brick) then
                if (brick.locked == 1 and self.hasKey == false) then
                    gSounds['wall-hit']:play()
                else

                    if( brick.locked) then 
                        -- add MORE points if a locked block is unlocked
                        self.score = self.score + (brick.tier * 500 + brick.color * 100)

                    else
                        -- add to score
                        self.score = self.score + (brick.tier * 200 + brick.color * 25)
                    end 

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit(self.hasKey)
                end 

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- grow paddle
                    if (self.paddle.size < 4) then
                        self.paddle.size = self.paddle.size + 1
                    end

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + self.recoverPoints * 2

                    print('recoverPoints', self.recoverPoints)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = iBall,
                        recoverPoints = self.recoverPoints,
                        nextPowerUp = self.nextPowerUp,
                        powerUp_Timer = self.powerUp_Timer       
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if iBall.x + 2 < brick.x and iBall.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    iBall.dx = -iBall.dx
                    iBall.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif iBall.x + 6 > brick.x + brick.width and iBall.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    iBall.dx = -iBall.dx
                    iBall.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif iBall.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    iBall.dy = -iBall.dy
                    iBall.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    iBall.dy = -iBall.dy
                    iBall.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(iBall.dy) < 150 then
                    iBall.dy = iBall.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end

        end
    end

    for i, iBall in ipairs(self.ballsArray) do
        -- if ball goes below bounds, revert to serve state and decrease health
        if iBall.y >= VIRTUAL_HEIGHT then

            table.remove(self.ballsArray, i)

            gSounds['hurt']:play()
            
            if (table.getn(self.ballsArray) == 0) then
                self.health = self.health - 1

                -- shrink paddle
                if (self.paddle.size > 1) then
                    self.paddle.size = self.paddle.size - 1
                end                 

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints,
                        nextPowerUp = self.nextPowerUp,
                        powerUp_Timer = self.powerUp_Timer
                    })
                end
            end            
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- if love.keyboard.wasPressed('b') then
    --     ServeState:addBall(self)
    -- end

    -- if love.keyboard.wasPressed('p') then
    --     self.powerUp = PowerUp()
    -- end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for i, iBall in ipairs(self.ballsArray) do
        iBall:render()
    end

    if (self.powerUp ~= nil)then        
        self.powerUp:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    if (self.hasKey == true) then 
        love.graphics.draw(gTextures['main'], gFrames['powerups'][4], VIRTUAL_WIDTH - 120, 1)
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end



