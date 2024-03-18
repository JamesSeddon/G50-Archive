
PowerUp = Class{}

function PowerUp:init(skin)

    

    -- simple positional and dimensional variables
    self.width = 8
    self.height = 8

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 30
    self.dx = 0

    self.x = VIRTUAL_WIDTH / 2 - math.random(-200, 200)
    self.y = VIRTUAL_HEIGHT / 2 - 100

    -- 3 = extra ball
    -- 4 = key 

    self.powerType = math.random(4)

    if (self.powerType < 4) then --  not all powerups implemented, if it's not a key, then its extra ball (25% chance of key)
        self.powerType = 3
    end

    print('init powerup', self.powerType )
end

function PowerUp:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function PowerUp:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function PowerUp:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.powerType], self.x, self.y)

end