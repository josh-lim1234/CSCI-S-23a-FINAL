--[[
    GD50
    Super Mario Bros. Remake

    -- BlueBlueBlueSnailMovingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnailMovingState = Class{__includes = BaseState}

function BlueSnailMovingState:init(tilemap, player, bluesnail)
    self.tilemap = tilemap
    self.player = player
    self.bluesnail = bluesnail
    self.animation = Animation {
        frames = {53, 54},
        interval = 0.5
    }
    self.bluesnail.bluecurrentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.bluesnail.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
    self.state = 'notpara'
end

function BlueSnailMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.bluesnail.bluecurrentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.bluesnail:changeState('idle', {

                -- random amount of time for bluesnail to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.bluesnail.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.bluesnail.direction == 'left' then
        self.bluesnail.x = self.bluesnail.x - SNAIL_MOVE_SPEED * dt

        -- stop the bluesnail if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y + self.bluesnail.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.bluesnail.x = self.bluesnail.x + SNAIL_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.bluesnail.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.bluesnail.direction = 'right'
        self.bluesnail.x = self.bluesnail.x + SNAIL_MOVE_SPEED * dt

        -- stop the bluesnail if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y)
        local tileBottomRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y + self.bluesnail.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.bluesnail.x = self.bluesnail.x - SNAIL_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.bluesnail.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between bluesnail and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.bluesnail.x)

    if diffX < 5 * TILE_SIZE then
        self.bluesnail:changeState('chasing')
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