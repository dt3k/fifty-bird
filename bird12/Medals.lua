--[[
    Medals Class
    Author: Matthew Harjo
    matt.harjo@gmail.com

    The Medals class is a simple way to check medal status, add in the images and keep
    them outside of the main.lua
]]

Medals = Class{}

BRONZE_AWARD = 1
SILVER_AWARD = 2
GOLD_AWARD = 3

MEDAL_SPEED = -1500


function Medals:init()
    medal = {
        ['bronze'] = love.graphics.newImage('assets/medal_bronze.png'),
        ['silver'] = love.graphics.newImage('assets/medal_silver.png'),
        ['gold'] = love.graphics.newImage('assets/medal_gold.png'),
    }
    medalHome = {
        ['bronze'] = 10,
        ['silver'] = 44,
        ['gold'] = 78
    }
    self.achievement = 'none'
    self.medalInMotion = false
    self.bronzeMedalWon = false
    self.silverMedalWon = false
    self.goldMedalWon = false
end

function Medals:checkIfWon(score)
    --[[ check to see if we gained an achievement and play a sound 
         honestly, this feels clunky
    ]]
    if score >= BRONZE_AWARD and not self.bronzeMedalWon then
        sounds['whoosh']:play()
        self.bronzeMedalWon = true
        self.achievement = 'bronze'
        self.medalInMotion = true
        self.medalx = VIRTUAL_WIDTH
    end
    if score >= SILVER_AWARD and not self.silverMedalWon then
        sounds['whoosh']:play()
        self.silverMedalWon = true
        self.achievement = 'silver'
        self.medalInMotion = true
        self.medalx = VIRTUAL_WIDTH
    end
    if score >= GOLD_AWARD and not self.goldMedalWon then
        sounds['whoosh']:play()
        self.goldMedalWon = true
        self.achievement = 'gold'
        self.medalInMotion = true
        self.medalx = VIRTUAL_WIDTH
    end
end

-- test to see if I can get the medal to swoop in
function Medals:update(dt)

    if not self.medalInMotion then
        return
    end

    minX = medalHome[self.achievement]

    self.medalx = math.max(minX, self.medalx + MEDAL_SPEED * dt)

    if self.medalx == minX then
        self.medalInMotion = false
        sounds['clank']:play()
    end

end

-- This function just displays the current achievement in the lower left portion of the screen
function Medals:render()
    
    if self.bronzeMedalWon then 
        if self.medalInMotion and self.achievement == 'bronze' then
            love.graphics.draw(medal['bronze'], self.medalx, VIRTUAL_HEIGHT - 70) 
        else
            love.graphics.draw(medal['bronze'], medalHome['bronze'], VIRTUAL_HEIGHT - 70)
        end
    end
    if self.silverMedalWon then 
        if self.medalInMotion and self.achievement == 'silver' then
            love.graphics.draw(medal['silver'], self.medalx, VIRTUAL_HEIGHT - 70) 
        else
            love.graphics.draw(medal['silver'], medalHome['silver'], VIRTUAL_HEIGHT - 70)
        end
    end
    if self.goldMedalWon then 
        if self.medalInMotion and self.achievement == 'gold' then
            love.graphics.draw(medal['gold'], self.medalx, VIRTUAL_HEIGHT - 70) 
        else
            love.graphics.draw(medal['gold'], medalHome['gold'], VIRTUAL_HEIGHT - 70)
        end
    end
end

function Medals:renderFinal(achievement)
    if achievement == 'none' then
        -- do nothing
    else
        love.graphics.draw(medal[achievement], VIRTUAL_WIDTH / 2 - 24, VIRTUAL_HEIGHT / 2 - 34)
    end
end
