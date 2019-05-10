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
    blip.x = blip.x + blip.dx
    blip.y = blip.y + blip.dy
    blip.age = blip.age + dt
    local r_x, r_y = lume.vector(radar.angle, 500)
    local z = game.line_intercepts_circle(radar.x, radar.y, r_x + radar.x, r_y + radar.y, blip.x, blip.y, 10, radar.angle)
    if z then
      blip.age = 0
    end
  end
  radar.angle = radar.angle + 0.01
  if radar.angle >= 2*math.pi then
    radar.angle = radar.angle - 2*math.pi
  end
end

function game.draw()
  love.graphics.setColor(1.0, 1.0, 1.0)
  local r_x, r_y = lume.vector(radar.angle, 500)
  for i, blip in ipairs(blips) do
    local z = game.line_intercepts_circle(radar.x, radar.y, r_x + radar.x, r_y + radar.y, blip.x, blip.y, 10, radar.angle)
    if z then
      love.graphics.setColor(1.0, 0.0, 0.0, 2.0-blip.age)
    else
      love.graphics.setColor(1.0, 1.0, 1.0, 2.0-blip.age)
    end
    love.graphics.circle('fill', blip.x, blip.y, 10, 10)
    love.graphics.setColor(1.0, 0.0, 1.0)
  end
  love.graphics.setColor(0.0, 1.0, 1.0)
  love.graphics.line(radar.x,radar.y,radar.x + r_x, radar.y + r_y)
  love.graphics.line(radar.x,radar.y,radar.x - r_x, radar.y - r_y)
end

function game.line_intercepts_circle(x1, y1, x2, y2, cX, cY, cR, radar_angle)
  dxdy = ((y2 - y1)/(x2 - x1))
  a = -dxdy
  b = 1.0
  c = - (y1 - dxdy*x1)
  d = math.abs((a*cX) + (b*cY) + c) / math.sqrt((a*a) + (b*b))
  return d < cR
end

function game.make_torpedo(x, y, dx, dy)
end

function game.make_radar(x, y, angle)
  return {
    x = x,
    y = y,
    angle = angle
  }
end

function game.make_ship_blip(x, y)
  return {
    x = x,
    y = y,
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
    dx = 0,
    dy = 0,
    hp = 0,
    age = 0,
    type = "ghost"
  }
end

return game
