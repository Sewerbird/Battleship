local lib = require('ed')

local Blip = require('blip')

local Radar = lib.class({
  type = "radar",
  x = 0,
  y = 0,
  angle = 0,
  hertz = 0.1,
  false_positive_rate = -1, -- Ghosts per second
  false_positive_accumulator = 0,
  distance = 500,
})
:implements("Sensor")
:implements("Orientable")
:implements("Equippable")
:implements("Drawable")
:implements("Updatable")

function Radar:update(dt, equipper)
  self.x = equipper.x
  self.y = equipper.y
  self.angle = lume.wrap(self.angle + (self.hertz * dt * 2 * math.pi), 0, 2*math.pi)
  self.false_positive_accumulator = self.false_positive_accumulator + (self.false_positive_rate * dt)
  -- Check Radar for new blips (ghosts or ships)
  -- True Positives
  for _, ship in ipairs(game.get_ships()) do
    if geom.line_intercepts_circle(self, ship) and ship.id ~= equipper.id and ship.id ~= self.equipper_id then
      table.insert(game.get_blips(), Blip:create({x= ship.x, y= ship.y, r= ship.r}))
      love.audio.play(game.get_sounds().pings.blip_1)
    end
  end
  return self
end

function Radar:draw(equipper)
  local r_x, r_y = lume.vector(self.angle, self.distance)
  love.graphics.setColor(1.0, 1.0, 1.0)
  love.graphics.line(self.x,self.y,self.x + r_x, self.y + r_y)
  love.graphics.line(self.x,self.y,self.x - r_x, self.y - r_y)
end

function Radar:onEquip(equipper)
  self.equipper_id = equipper.id
  self.x = equipper.x
  self.y = equipper.y
  self.angle = equipper.angle
  return self
end

return Radar
