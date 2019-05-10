local game = {}

local blips = {}
local radar = {}

function game.load()
  love.math.setRandomSeed(love.math.getRandomSeed())
  for i = 0, 3 do
    local r_x = love.math.random() * love.graphics.getWidth()
    local r_y = love.math.random() * love.graphics.getHeight()
    table.insert(blips, game.make_ship_blip(r_x, r_y))
  end
  for i = 0, 10 do
    local r_x = love.math.random() * love.graphics.getWidth()
    local r_y = love.math.random() * love.graphics.getHeight()
    table.insert(blips, game.make_ghost_blip(r_x, r_y))
  end
  radar = game.make_radar(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0)
end

function game.update(dt)
  for i, blip in ipairs(blips) do
    blip.x = lume.wrap(blip.x + blip.dx, 0, love.graphics.getWidth())
    blip.y = lume.wrap(blip.y + blip.dy, 0, love.graphics.getHeight())
    blip.age = blip.age + dt
    -- Refresh blips that are seen by radar
    if game.line_intercepts_circle(radar, blip) then
      blip.age = 0
    end
    -- Detect collisions of torpedoes hitting ships
    for j, other in ipairs(blips) do
      if ((blip.type == "torpedo" and other.type == "ship") or 
          (blip.type == "ship" and other.type == "torpedo")) and
         game.circle_intercepts_circle(blip, other) then
         blip.destroy = true
         other.destroy = true
       end
    end
  end
  -- Remove destroyed things
  for i=#blips,1,-1 do
    if blips[i].destroy then
      table.remove(blips, i)
    end
  end
  -- Update radar scan azimuth
  radar.angle = radar.angle + 0.01
  if radar.angle >= 2*math.pi then
    radar.angle = radar.angle - 2*math.pi
  end
end

function game.draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  local r_x, r_y = lume.vector(radar.angle, 500)
  for i, blip in ipairs(blips) do
    --Fade blips according to time since last detection
    local fadeout = 2.0
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0 * ((fadeout-blip.age)/fadeout))
    love.graphics.circle('fill', blip.x, blip.y, 10, 10)
  end
  --Draw radar sweep
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.line(radar.x,radar.y,radar.x + r_x, radar.y + r_y)
  love.graphics.line(radar.x,radar.y,radar.x - r_x, radar.y - r_y)
end

-- Lines have a point (x,y) and an angle (angle)
-- Circles have a center point (x,y) and a radius (r)
function game.line_intercepts_circle(line, circle)
  assert(game.is_a_line(line))
  assert(game.is_a_circle(circle))
  local x1 = line.x
  local y1 = line.y
  local r_x, r_y = lume.vector(line.angle, 1)
  local x2 = x1 + r_x
  local y2 = x1 + r_y
  local cX = circle.x
  local cY = circle.y
  local cR = circle.r
  local dxdy = ((y2 - y1)/(x2 - x1))
  local a = -dxdy
  local b = 1.0
  local c = - (y1 - dxdy*x1)
  local d = math.abs((a*cX) + (b*cY) + c) / math.sqrt((a*a) + (b*b))
  return d < cR
end

-- Circles have a center point (x,y) and a radius (r)
function game.circle_intercepts_circle(circleA, circleB)
  assert(game.is_a_circle(circleA))
  assert(game.is_a_circle(circleB))
  local D = math.sqrt(math.pow(circleB.x - circleA.x, 2) + math.pow(circleB.y - circleA.y, 2))
  return D < (circleA.r + circleB.r)
end

function game.is_a_line(line)
  return line.x and line.y and line.angle
end

function game.is_a_circle(circle)
  return circle.x and circle.y and circle.r 
end

function game.fire_torpedo(x, y)
  local x0 = love.graphics.getWidth()/2
  local y0 = love.graphics.getHeight()/2
  local D = math.sqrt(math.pow(x-x0,2) + math.pow(y-y0,2))
  local dx = x-x0
  local dy = y-y0
  table.insert(blips, game.make_torpedo(x0, y0, dx/D, dy/D))
end

function game.make_radar(x, y, angle)
  return {
    x = x,
    y = y,
    angle = angle
  }
end

function game.make_torpedo(x, y, dx, dy)
  return {
    x = x,
    y = y,
    r = 10,
    dx = dx,
    dy = dy,
    age = 0,
    hp = 1,
    type = "torpedo"
  }
end

function game.make_ship_blip(x, y)
  return {
    x = x,
    y = y,
    r = 10,
    dx = 0,
    dy = 1,
    hp = 1,
    age = 0,
    type = "ship"
  }
end

function game.make_ghost_blip(x, y)
  return {
    x = x,
    y = y,
    r = 10,
    dx = 0,
    dy = 0,
    hp = 0,
    age = 0,
    type = "ghost"
  }
end

return game
