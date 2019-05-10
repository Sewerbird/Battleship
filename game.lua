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
    if blip.type == "torpedo" then blip.age = 0 end
    local r_x, r_y = lume.vector(radar.angle, 500)
    local z = game.line_intercepts_circle(radar.x, radar.y, r_x + radar.x, r_y + radar.y, blip.x, blip.y, 10)
    if z then
      blip.age = 0
    end
    for j, other in ipairs(blips) do
      if (i ~= j) and 
         ((blip.type == "torpedo" and other.type == "ship") 
           or (blip.type == "ship" and other.type == "torpedo")) and
         (game.circle_intercepts_circle(blip.x, blip.y, 10, other.x, other.y, 10)) then
         blip.destroy = true
         other.destroy = true
       end
    end
  end

  for i=#blips,1,-1 do
    if blips[i].destroy then
      table.remove(blips, i)
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
    --Fade blips according to time since last detection
    local fadeout = 2.0
    if blip.age == 0 then
      love.graphics.setColor(1.0, 0.0, 0.0, 1.0 * ((fadeout-blip.age)/fadeout))
    else
      love.graphics.setColor(1.0, 1.0, 1.0, 1.0 * ((fadeout-blip.age)/fadeout))
    end
    love.graphics.circle('fill', blip.x, blip.y, 10, 10)
  end
  --Draw radar sweep
  love.graphics.setColor(0.0, 1.0, 1.0)
  love.graphics.line(radar.x,radar.y,radar.x + r_x, radar.y + r_y)
  love.graphics.line(radar.x,radar.y,radar.x - r_x, radar.y - r_y)
end

function game.line_intercepts_circle(x1, y1, x2, y2, cX, cY, cR)
  dxdy = ((y2 - y1)/(x2 - x1))
  a = -dxdy
  b = 1.0
  c = - (y1 - dxdy*x1)
  d = math.abs((a*cX) + (b*cY) + c) / math.sqrt((a*a) + (b*b))
  return d < cR
end

function game.circle_intercepts_circle(cx1, cy1, cr1, cx2, cy2, cr2)
  local D = math.sqrt(math.pow(cx2 - cx1, 2) + math.pow(cy2 - cy1, 2))
  return D < (cr2 + cr1)
end

function game.fire_torpedo(x, y)
  local x0 = love.graphics.getWidth()/2
  local y0 = love.graphics.getHeight()/2
  local D = math.sqrt(math.pow(x-x0,2) + math.pow(y-y0,2))
  local dx = x-x0
  local dy = y-y0
  table.insert(blips, game.make_torpedo(x0, y0, dx/D, dy/D))
end

function game.make_torpedo(x, y, dx, dy)
  return {
    x = x,
    y = y,
    dx = dx,
    dy = dy,
    age = 0,
    hp = 1,
    type = "torpedo"
  }
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
