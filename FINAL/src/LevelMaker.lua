--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height)
    invincibility = false
    local tiles = {}
    local entities = {}
    local objects = {}

    local tileID = TILE_ID_GROUND
    
    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        keyexists = false
        lockexists = false
        obtained = false

        table.insert(tiles, {})
    end

    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        ovrlap = true
        local tileID = TILE_ID_EMPTY
        
        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        -- chance to just be emptiness
        if math.random(7) == 1 and x ~= width - 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
            end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 and x ~= width - 1 then
                blockHeight = 2
                
                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,
                            
                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end
                
                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            
            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            -- chance to spawn a block
            if math.random(10) == 1 and x ~= width - 1 then
                ovrlap = false
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                        end
                                    }
                                    
                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
            if math.random(5) == 1 and keyexists == false and x ~= 1 and x ~= 2 and ovrlap == true then
                ovrlap = false
                keyexists = true
                color = math.random(#KEY_BLOCKS)
                local key = GameObject {
                texture = 'keys',
                x = (x - 1) * TILE_SIZE,
                y = (blockHeight - 1) * TILE_SIZE - 4,
                width = 16,
                height = 16,
                frame = color,
                collidable = true,
                consumable = true,
                solid = false,

                onConsume = function(player, object)
                    obtained = true
                    gSounds['pickup']:play()
                end
                }
                table.insert(objects, key)

            end
            if math.random(5) == 1 and lockexists == false and keyexists == true and ovrlap == true then
              lockexists = true
              lockpos = table.getn(objects)
              
              table.insert(objects,

                  GameObject {
                      texture = 'keys',
                      x = (x - 1) * TILE_SIZE,
                      y = (blockHeight - 1) * TILE_SIZE,
                      width = 16,
                      height = 16,

                      -- make it a random variant
                      frame = color + 4,
                      collidable = true,
                      consumable = false,
                      hit = false,
                      solid = true,

                      -- collision function takes itself
                      onCollide = function(obj)
                        if obtained == true and objects[lockpos].texture == 'keys' then
                          table.remove(objects, lockpos)
                          table.insert(objects,

                              GameObject {
                                  texture = 'flag',
                                  x = (width - 1 - 1) * TILE_SIZE + 7,
                                  y = 3 * TILE_SIZE,
                                  width = 16,
                                  height = 16,
                                  frame = 25,
                                  collidable = true,
                                  consumable = true,
                                  solid = false,  

                                  onConsume = function(player, object)
                                    gStateMachine:change('play', {
                                        leveln = leveln + 1,
                                        width = width * 1.5,
                                    })
                                  end
                              }
                          )
                          table.insert(objects,

                              GameObject {
                                  texture = 'flag',
                                  x = (width - 1 - 1) * TILE_SIZE,
                                  y = 3 * TILE_SIZE,
                                  width = 16,
                                  height = 16,
                                  frame = 5,
                                  collidable = true,
                                  consumable = true,
                                  solid = false,

                                  onConsume = function(player, object)
                                    gStateMachine:change('play', {
                                        leveln = leveln + 1,
                                        width = width * 1.5,
                                    })
                                  end
                              }
                          )
                          table.insert(objects,

                              GameObject {
                                  texture = 'flag',
                                  x = (width - 1 - 1) * TILE_SIZE,
                                  y = 4 * TILE_SIZE,
                                  width = 16,
                                  height = 16,
                                  frame = 14,
                                  collidable = true,
                                  consumable = true,
                                  solid = false,

                                  onConsume = function(player, object)
                                    gStateMachine:change('play', {
                                        leveln = leveln + 1,
                                        width = width * 1.5,
                                    })
                                  end
                              }
                          )
                          table.insert(objects,

                              GameObject {
                                  texture = 'flag',
                                  x = (width - 1 - 1) * TILE_SIZE,
                                  y = 5 * TILE_SIZE,
                                  width = 16,
                                  height = 16,
                                  frame = 14,
                                  collidable = true,
                                  consumable = true,
                                  solid = false,

                                  onConsume = function(player, object)
                                    gStateMachine:change('play', {
                                        leveln = leveln + 1,
                                        width = width * 1.5,
                                    })
                                  end
                              }
                          )
                          -- maintain reference so we can set it to nil
                          local gem = GameObject {
                              texture = 'star',
                              x = (x - 1) * TILE_SIZE,
                              y = (blockHeight - 1) * TILE_SIZE - 4,
                              width = 16,
                              height = 16,
                              frame = 6,
                              collidable = true,
                              consumable = true,
                              solid = false,

                              -- gem has its own function to add to the player's score
                              onConsume = function(player, object)
                                  gSounds['pickup']:play()
                                  invincibleTimer = 0
                              end
                          }
                          
                          -- make the gem move up from the block and play a sound
                          Timer.tween(0.1, {
                              [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                          })
                          gSounds['powerup-reveal']:play()

                          table.insert(objects, gem)
                        end
                      end
                    
                  }
              )
              table.insert(objects, lock)
            end
        end
    end

    local map = TileMap(width, height)

    map.tiles = tiles
    for x = 1, width do
      if map.tiles[10][x].id ~= 5 then
        validx = x
        break
      end
    end
    
    return GameLevel(entities, objects, map)
end