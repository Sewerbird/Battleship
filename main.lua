lume = require 'lib/lume'
lume.wrap = function(value, minimum, maximum)
  local range = maximum - minimum
  while value < minimum do
    value = value + range
  end
  while value > maximum do
    value = value - range
  end
  return value
end
game = require 'game'
moonshine = require 'moonshine'
frame_rate = 0;

--Global Gamestate
function love.load(args)
  effect = moonshine(moonshine.effects.crt)
              .chain(moonshine.effects.scanlines)
              .chain(moonshine.effects.glow)
              --.chain(moonshine.effects.dmg)
  --effect.dmg.palette = "green"
  effect.glow.strength = 10
  game.load()
end

function love.keypressed(key)
end

function love.touchpressed(x,y)
  love.mousepressed(x,y)
end

function love.mousepressed(x,y)
  game.fire_torpedo(x,y)
end

function love.mousemoved(x,y,dx,dy)
end

function love.mousereleased(x,y)
end

function love.update(dt)
  frame_rate = 1.0 / dt
  game.update(dt)
end

function love.draw()
  love.graphics.print(math.floor(frame_rate), 10, 10)
  effect(function()
    game.draw()
  end)
end

