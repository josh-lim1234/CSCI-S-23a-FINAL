--[[
    GD50
    Super Mario Bros. Remake

    -- BlueSnailParalysedState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnailParalysedState = Class{__includes = BaseState}

function BlueSnailParalysedState:init(tilemap, player, bluesnail)
    self.tilemap = tilemap
    self.player = player
    self.bluesnail = bluesnail
    self.waitTimer = 0
    self.animation = Animation {
        frames = {55},
        interval = 1
    }
    self.bluesnail.bluecurrentAnimation = self.animation
    self.state = 'para'
end

function BlueSnailParalysedState:enter(params)
    self.waitPeriod = params.wait
end

function BlueSnailParalysedState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.bluesnail:changeState('moving')
    end

    if self.bluesnail:collides(self.player) and falling == false and self.player.x > self.bluesnail.x then
      self.bluesnail.x = self.bluesnail.x - 100 * dt
      local tileLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y)
      local tileBottomLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y + self.bluesnail.height)

      if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
          self.bluesnail.x = self.bluesnail.x + 100 * dt
          self.shelldir = 'right'
          self.bluesnail.direction = 'right'
      end
      self.bluesnail:changeState('movingshell', {

          -- random amount of time for bluesnail to be idle
          wait = 5,
          dir = 'left'
      })    
    elseif self.bluesnail:collides(self.player) and falling == false and self.player.x < self.bluesnail.x then
      self.bluesnail.x = self.bluesnail.x + 100 * dt
      local tileRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y)
      local tileBottomRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y + self.bluesnail.height)
      if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
          self.bluesnail.x = self.bluesnail.x - 100 * dt
          self.shelldir = 'left'
          self.bluesnail.direction = 'left'
      end
      self.bluesnail:changeState('movingshell', {

          -- random amount of time for bluesnail to be idle
          wait = 5,
          dir = 'right'
      })    
    end
end