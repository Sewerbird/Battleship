local Blip = require('blip')

local Sonar = {}
Sonar.__index = Sonar

function Sonar:create(options)
  options = options or {}
  local this = {
    type = "sonar",
    x = options.x or 0,
    y = options.y or 0,
    r = options.r or 1000000000,
    dr = options.dr or 90,
    false_positive_rate = options.false_positive_rate or -1, -- Ghosts per second
    false_positive_accumulator = options.false_positive_accumulator or 0,
    distance = options.distance or 1500
  }
  setmetatable(this, Sonar)
  return this
end

function Sonar:update(dt, equipper)
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  self.x = equipper.x
  self.y = equipper.y
  self.r = math.min(self.r + (self.dr * dt), 1.1 * math.sqrt(w*w + h*h))
  self.false_positive_accumulator = self.false_positive_accumulator + (self.false_positive_rate * dt)
  -- Check Sonar for new blips (ghosts or ships)
  -- True Positives
  for _, ship in ipairs(game.get_ships()) do
    if geom.circle_intercepts_circle(self, ship) and ship.id ~= -1 then
      table.insert(game.get_blips(), Blip:create({x= ship.x, y= ship.y, ship.r}))
      love.audio.play(game.get_sounds().pings.sonar_1)
    end
  end
  -- False Positives
  for _ = 0, self.false_positive_accumulator do
    self.false_positive_accumulator = self.false_positive_accumulator - 1
    local fp_x, fp_y = lume.vector(love.math.random() * 2 * math.pi, self.r)
    table.insert(game.get_blips(), Blip:create({x= self.x + fp_x, y= self.y + fp_y, r= love.math.random() * 5}))
    love.audio.play(game.get_sounds().pings.self_1)
  end
  return self
end

function Sonar:draw(equipper)
  --Draw sonar ping
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.circle('line', self.x, self.y, self.r, self.r)
end

function Sonar:onEquip(equipper)
  self.x = equipper.x
  self.y = equipper.y
  self.angle = equipper.angle
  return self
end

return Sonar
