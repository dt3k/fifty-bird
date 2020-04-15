--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

-- to enable the pause 
pause = false

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    self.medals = Medals()
    self.medals.achievement = 'none'

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)

    --[[
        There's probably a very elegant way to transition from play to pause state and this
        is what I tried in the beginning.  Truth is I couldn't get the transition to work
        and this seemed to be much easier than implementing a whole new state.
    ]]

    -- check for pause - must be done before our pause loop
    if love.keyboard.wasPressed('p') then
        pause = not pause and true or false
        if pause then sounds['pause']:play() end
    end

    -- this is where our pause loop ends if we are paused
    if pause then
        scrolling = false
        sounds['music']:pause()
        return -- don't do anything else
    else
        scrolling = true
        sounds['music']:play()
    end

    -- update timer for pipe spawning
    self.timer = self.timer + dt

    -- spawn a new pipe pair every second and a half
    if self.timer > 2 then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length (90 pixels) from the bottom
        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y))

        -- reset timer with a random 0-2 seconds more than 2 seconds
        local randomInterval = love.math.random(-2,0) -- this seemed easiest
        self.timer = 0 + randomInterval
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', { 
                    score = self.score, 
                    achievement = self.medals.achievement
                })
            end
        end
    end

    -- update medals if any are in motion
    self.medals:update(dt)

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        gStateMachine:change('score', {
            score = self.score,
            achievement = self.medals.achievement,
        })
    end

    -- check to see if you've won a (new) medal
    self.medals:checkIfWon(self.score)

--[[
        gStateMachine:change('pause', {
            bird = self.bird,
            pipes = self.pipePairs[],
            score = self.score,
            timer = self.timer,
            medals = self.medals,
            achievement = self.medals.achievement,
        }
    )
    end]]
    
    -- Just turn music on/off with 'm' key
    if love.keyboard.wasPressed('m') then
        if musicOn then 
            sounds['music']:pause() 
            musicOn = false
        else
            sounds['music']:play()
            musicOn = true
        end
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    -- debug any music issues
    if musicOn then
        musicState = 'On'
    else
        musicState = 'Off'
    end
    if DEBUG == true then 
        love.graphics.print('Music: ' .. tostring(musicState), 8, 40)
    end
    -- end debug

    if pause then
        love.graphics.setFont(hugeFont)
        love.graphics.printf('Paused', 0, 100, VIRTUAL_WIDTH, 'center')
    end

    self.medals:render()
    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter(params)
    -- if we're coming from death, restart scrolling
    scrolling = true
    --[[if params then
        self.bird = params.bird
        self.pipePairs = params.pipePairs
        self.timer = params.timer
        self.score = params.score
        self.medals = params.medals
        self.medals.achievement = params.medals.achievement
    end]]
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end