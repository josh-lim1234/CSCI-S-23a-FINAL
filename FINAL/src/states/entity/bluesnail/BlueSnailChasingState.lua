--[[
    GD50
    Super Mario Bros. Remake

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnailChasingState = Class{__includes = BaseState}

function BlueSnailChasingState:init(tilemap, player, bluesnail)
    self.tilemap = tilemap
    self.player = player
    self.bluesnail = bluesnail
    self.animation = Animation {
        frames = {53, 54},
        interval = 0.5
    }
    self.state = 'notpara'
    self.bluesnail.bluecurrentAnimation = self.animation
end

function BlueSnailChasingState:update(dt)
    self.bluesnail.bluecurrentAnimation:update(dt)

    -- calculate difference between bluesnail and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.bluesnail.x)

    if diffX > 5 * TILE_SIZE then
        self.bluesnail:changeState('moving')
    elseif self.player.x < self.bluesnail.x then
        self.bluesnail.direction = 'left'
        self.bluesnail.x = self.bluesnail.x - SNAIL_MOVE_SPEED * dt

        -- stop the bluesnail if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y + self.bluesnail.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.bluesnail.x = self.bluesnail.x + SNAIL_MOVE_SPEED * dt
        end
    else
        self.bluesnail.direction = 'right'
        self.bluesnail.x = self.bluesnail.x + SNAIL_MOVE_SPEED * dt

        -- stop the bluesnail if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y)
        local tileBottomRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y + self.bluesnail.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.bluesnail.x = self.bluesnail.x - SNAIL_MOVE_SPEED * dt
        end
    end
    if self.bluesnail:collides(self.player) and falling == true then
      self.bluesnail:changeState('paralysed', {

          -- random amount of time for bluesnail to be idle
          wait = 10
      })
    elseif self.bluesnail:collides(self.player) and falling == false and invincibility == false then
      gSounds['death']:play()
      gStateMachine:change('start')
      invincibility = false
    end
end