local Blip = {}
Blip.__index = Blip

function Blip:create(options)
  local this = {
    x = options.x or 0,
    y = options.y or 0,
    r = options.r or 10,
    age = options.age or 0,
    max_age = options.max_age or 1,
  }
  setmetatable(this, Blip)
  return this
end

function Blip:update(dt)
  self.age = self.age + dt
  self.destroy = self.age > self.max_age
end

function Blip:draw()
  --Fade blips according to time since last detection
  local fadeout = (2.0 - self.age)/2.0
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0 * fadeout)
  love.graphics.circle('fill', self.x, self.y, self.r, self.r)
end

return Blip
