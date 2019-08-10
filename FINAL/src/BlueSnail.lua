--[[
    GD50
    Super Mario Bros. Remake

    -- Snail Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnail = Class{__includes = Entity}

function BlueSnail:init(def)
    Entity.init(self, def)
end

function BlueSnail:render()
  if self.bluecurrentAnimation:getCurrentFrame() == nil then
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][57],
        math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
  else
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.bluecurrentAnimation:getCurrentFrame()],
        math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
  end
end