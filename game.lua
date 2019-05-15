--Libs
local love = love
local lume = lume

--Deps
local Ship = require('ship')
local Torpedo = require('torpedo')
local Sonar = require('sonar')
local Radar = require('radar')

--State
local game = {}
local blips = {}
local ships = {}
local torpedoes = {}
local input = {}
local images = {
  maps = {
    archipelago = love.graphics.newImage("map.png")
  }
}
local sounds = {
  actions = {
    sonar_ping = function() local z = love.audio.newSource("sonar_ping.wav","static"); love.audio.play(z) end,
    torpedo_launch = function() local z = love.audio.newSource("torpedo_launch.wav","static"); love.audio.play(z) end,
  },
  pings = {
    blip_1 = love.audio.newSource("blip_1.wav","static"),
    hit_1 = love.audio.newSource("hit_1.wav","static"),
    sonar_1 = love.audio.newSource("sonar_1.wav","static"),
  }
}

function game.get_images()
  return images
end

function game.get_ships()
  return ships
end

function game.get_blips()
  return blips
end

function game.get_sounds()
  return sounds
end

--Functions
function game.load()
  love.math.setRandomSeed(love.math.getRandomSeed())
  --Place Enemy Ships
  for _ = 0, 3 do
    local enemy_ship = Ship:create({x= love.math.random() * love.graphics.getWidth(), y= love.math.random() * love.graphics.getHeight(), r= 10})
    table.insert(ships, enemy_ship)
  end
  --Place Player Ship
  local player_ship = Ship:create({x= love.graphics.getWidth()/2, y= love.graphics.getHeight()/2, r= 10, id= -1,
    equipment= {
      radar= Radar:create(),
      sonar= Sonar:create(),
    }})
  table.insert(ships, player_ship)
end

function game.commit_input(frame_input)
  input = frame_input
end

function game.cleanup(pool)
  for i = #pool,1,-1 do
    if pool[i].destroy then table.remove(pool, i) end
  end
end

function game.update(dt, input)
  for _, torpedo in ipairs(torpedoes) do
    torpedo:update(dt)
  end
  for _, blip in ipairs(blips) do
    blip:update(dt)
  end
  for _, ship in ipairs(ships) do
    ship:update(dt, input)
  end
  local player_ship, _ = lume.match(ships, function(e) return e.id == -1 end)

  --Cleanup
  game.cleanup(blips)
  game.cleanup(ships)
  game.cleanup(torpedoes)
end

function game.draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  --love.graphics.draw(images.maps.archipelago)
  for _, blip in ipairs(blips) do
    blip:draw()
  end
  for _, torpedo in ipairs(torpedoes) do
    torpedo:draw()
  end
  for _, ship in ipairs(ships) do
    ship:draw()
  end
end

function game.ping_sonar()
  sounds.actions.sonar_ping()
  local player_ship, _ = lume.match(ships, function(e) return e.id == -1 end)
  player_ship:get_module("sonar").r = 0
end

function game.fire_enemy_torpedo(ship, x, y)
  local x0 = love.graphics.getWidth()/2
  local y0 = love.graphics.getHeight()/2
  local D = math.sqrt(math.pow(x-x0,2) + math.pow(y-y0,2))
  local dx = x0 - x
  local dy = y0 - y
  local speed = 3
  table.insert(torpedoes, Torpedo:create({launcher= ship.id, x= x, y= y, dx= speed * dx/D, dy= speed * dy/D}))
end

function game.fire_torpedo(ship,x, y)
  sounds.actions.torpedo_launch()
  local player = ship
  local x0 = player.x
  local y0 = player.y
  local D = math.sqrt(math.pow(x-x0,2) + math.pow(y-y0,2))
  local dx = x-x0
  local dy = y-y0
  local speed = 3
  table.insert(torpedoes, Torpedo:create({launcher= -1, x= x0, y= y0, dx= speed * dx/D, dy= speed * dy/D}))
end

return game
