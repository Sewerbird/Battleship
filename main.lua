lume = require 'lib/lume'
game = require 'game'

--Global Gamestate
function love.load(args)
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
  game.draw()
end

