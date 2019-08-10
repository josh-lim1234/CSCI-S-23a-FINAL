--[[
    GD50
    Super Mario Bros. Remake

    -- BlueBlueBlueSnailMovingState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BlueSnailMovingShellState = Class{__includes = BaseState}

function BlueSnailMovingShellState:init(tilemap, player, bluesnail)
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

function BlueSnailMovingShellState:enter(params)
    self.waitPeriod = params.wait
    self.shelldir = params.dir
    self.initwait = self.waitPeriod
end

function BlueSnailMovingShellState:update(dt)
    if self.shelldir == 'right' then
      self.bluesnail.direction = 'right'
      self.bluesnail.x = self.bluesnail.x + 100 * dt
      local tileRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y)
      local tileBottomRight = self.tilemap:pointToTile(self.bluesnail.x + self.bluesnail.width, self.bluesnail.y + self.bluesnail.height)
      if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
          self.bluesnail.x = self.bluesnail.x - 100 * dt
          self.shelldir = 'left'
          self.bluesnail.direction = 'left'
      end
    elseif self.shelldir == 'left' then
      self.bluesnail.direction = 'left'
      self.bluesnail.x = self.bluesnail.x - 100 * dt  
      local tileLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y)
      local tileBottomLeft = self.tilemap:pointToTile(self.bluesnail.x, self.bluesnail.y + self.bluesnail.height)

      if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
          self.bluesnail.x = self.bluesnail.x + 100 * dt
          self.shelldir = 'right'
          self.bluesnail.direction = 'right'
      end
    end
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.bluesnail:changeState('moving')
    end   
    if self.bluesnail:collides(self.player) and falling == true then
      self.bluesnail:changeState('paralysed', {

          -- random amount of time for bluesnail to be idle
          wait = 10
      })    
    elseif self.bluesnail:collides(self.player) and falling == false then
        gSounds['death']:play()
        gStateMachine:change('start')
        invincibility = false
    end
    for k, entity in pairs(self.player.level.entities) do
        if self.bluesnail ~= entity then
          if self.bluesnail:collides(entity) then
              gSounds['kill']:play()
              gSounds['kill2']:play()
              self.player.score = self.player.score + 100
              table.remove(self.player.level.entities, k)
          end
        elseif self.bluesnail == entity and self.bluesnail:collides(self.player) and invincibility == true then
            table.remove(self.player.level.entities, k)
        end
    end
end