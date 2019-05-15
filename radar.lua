local Blip = require('blip')

local Radar = {}
Radar.__index = Radar

function Radar:create(options)
  local this = {
    x = options.x or 0,
    y = options.y or 0,
    angle = options.angle or 0,
    false_positive_rate = options.false_positive_rate or -1, -- Ghosts per second
    false_positive_accumulator = options.false_positive_accumulator or 0,
    hertz = options.hertz or 0.1,
    distance = options.distance or 500,
  }
  setmetatable(this, Radar)
  return this
end

function Radar:update(dt, equipper)
  self.x = equipper.x
  self.y = equipper.y
  self.angle = lume.wrap(self.angle + (self.hertz * dt * 2 * math.pi), 0, 2*math.pi)
  self.false_positive_accumulator = self.false_positive_accumulator + (self.false_positive_rate * dt)
  -- Check Radar for new blips (ghosts or ships)
  -- True Positives
  for _, ship in ipairs(game.get_ships()) do
    if geom.line_intercepts_circle(self, ship) and ship.id ~= -1 then
      table.insert(game.get_blips(), Blip:create({x= ship.x, y= ship.y, r= ship.r}))
      love.audio.play(game.get_sounds().pings.blip_1)
    end
  end
  -- False Positives
  for _ = 0, self.false_positive_accumulator do
    self.false_positive_accumulator = self.false_positive_accumulator - 1
    local fp_x, fp_y = lume.vector(self.angle, ((2.0 * love.math.random()) - 1.0) * self.distance)
    table.insert(game.get_blips(), Blip:create({x= self.x + fp_x, y= self.y + fp_y, r= love.math.random() * 5}))
    love.audio.play(game.get_sounds().pings.blip_1)
  end
  return self
end

function Radar:draw()
  local r_x, r_y = lume.vector(self.angle, self.distance)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.line(self.x,self.y,self.x + r_x, self.y + r_y)
  love.graphics.line(self.x,self.y,self.x - r_x, self.y - r_y)
end

return Radar
