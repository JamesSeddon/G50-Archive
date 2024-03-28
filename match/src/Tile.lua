--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = false
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself


    -- love.graphics.setColor(217/255, 87/255, 99/255, 1) 

    love.graphics.setColor(255, 255, 255, 255)

    
    if (self.shiny) then

        love.graphics.setShader(shinyShader)
        -- shinyShader:send("screen", {love.graphics.getWidth(), love.graphics.getHeight()})
        shinyShader:send("iTime", love.timer.getTime())
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][6], self.x + x, self.y + y)
        love.graphics.setShader()

    else
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)    

    end 
        
end