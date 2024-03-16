--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}



ShowMedal = false

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score

    ScoreMessage = 'Oof! You lost!'
    
    if (self.score >= 5) then

        ShowMedal = true
        ScoreMessage = 'WooHoo! You got a medal!'

        self.medal = love.graphics.newImage('bronze.png')

        if (self.score >= 10) then
            self.medal = love.graphics.newImage('silver.png')
        end

        if (self.score >= 20) then
            self.medal = love.graphics.newImage('gold.png')
        end
    end

end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        ShowMedal = false
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)   
    
    love.graphics.printf(ScoreMessage, 0, 64, VIRTUAL_WIDTH, 'center')

    if (ShowMedal) then
        love.graphics.draw(self.medal, 225, 120)
    end
    
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 180, VIRTUAL_WIDTH, 'center')
end