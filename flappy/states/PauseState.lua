--[[
    PauseState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Shown as the game's pause screen
]]

PauseState = Class{__includes = BaseState}

function PauseState:enter(params)

    sounds['music']:pause()
    sounds['pause']:play()

    -- store all game variables
    self.bird = params.bird
    self.pipePairs = params.pipePairs
    self.timer = params.timer
    self.score = params.score
    self.nextPipeTime = params.nextPipeTime
    self.lastY = params.lastY

end

function PauseState:update(dt)
    -- When P is pressed, show the countdown again and then play
    if love.keyboard.wasPressed('p') then

        sounds['pause']:play()
        sounds['music']:setLooping(true)
        sounds['music']:play()
        
        gStateMachine:change('countdown', {
            bird = self.bird,
            pipePairs = self.pipePairs,
            timer = self.timer,
            score = self.score,            
            nextPipeTime = self.nextPipeTime,
            lastY = self.lastY
        })
    end
end

function PauseState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)   
    
    love.graphics.printf('GAME PAUSED', 0, 64, VIRTUAL_WIDTH, 'center')
    
    love.graphics.printf('Press P to Continue', 0, 180, VIRTUAL_WIDTH, 'center')
end