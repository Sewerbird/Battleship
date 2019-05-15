local Torpedo = {}
Torpedo.__index = Torpedo

function Torpedo:create(options)
  local this = {
    x = options.x or 0,
    y = options.y or 0,
    r = options.r or 5,
    dx = options.dx or 0,
    dy = options.dy or 0,
    age = options.age or 0,
    max_age = options.max_age or 15,
    hp = options.hp or 1,
    live = options.live or true,
    launcher = options.launcher or nil,
  }
  setmetatable(this, Torpedo)
  return this
end

function Torpedo:update(dt)
  for _, ship in ipairs(game.get_ships()) do
    if geom.circle_collides_circle(ship, self) and self.live and self.launcher ~= ship.id then
      love.audio.play(game.get_sounds().pings.hit_1)
      self.dx = 0
      self.dy = 0
      self.live = false
      self.age = 0
      self.max_age = ship.max_sink_timer
      ship.dx = 0
      ship.dy = 0
      ship.is_sinking = true
    end
  end
  self.x = self.x + self.dx
  self.y = self.y + self.dy
  self.age = self.age + dt
  self.destroy = self.hp <= 0 or self.age > self.max_age
  return self
end

function Torpedo:draw()
  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  if not self.live then
    love.graphics.setColor(1.0, 0.0, 0.0, 1.0)
  end
  love.graphics.circle('fill', self.x, self.y, self.r, self.r)
end


return Torpedo
