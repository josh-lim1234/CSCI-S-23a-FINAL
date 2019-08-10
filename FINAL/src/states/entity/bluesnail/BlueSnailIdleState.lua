--[[
    GD50
    Super Mario Bros. Remake

    -- BlueSnailIdleState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnailIdleState = Class{__includes = BaseState}

function BlueSnailIdleState:init(tilemap, player, bluesnail)
    self.tilemap = tilemap
    self.player = player
    self.bluesnail = bluesnail
    self.waitTimer = 0
    self.animation = Animation {
        frames = {55},
        interval = 1
    }
    self.bluesnail.bluecurrentAnimation = self.animation
    self.state = 'notpara'
end

function BlueSnailIdleState:enter(params)
    self.waitPeriod = params.wait
end

function BlueSnailIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.bluesnail:changeState('moving')
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