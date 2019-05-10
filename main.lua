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

--Global Gamestate
function love.load(args)
  effect = moonshine(moonshine.effects.crt)
              .chain(moonshine.effects.scanlines)
              .chain(moonshine.effects.glow)
              .chain(moonshine.effects.dmg)
  effect.dmg.palette = "green"
  effect.glow.strength = 10
  game.load()
end

function love.keypressed(key)
end

function love.touchpressed(x,y)
end

function love.mousepressed(x,y)
end

function love.mousemoved(x,y,dx,dy)
end

function love.mousereleased(x,y)
end

function love.update(dt)
  game.update(dt)
end

function love.draw()
  effect(function()
    game.draw()
  end)
end

