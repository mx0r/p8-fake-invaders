Ufo = {
    x = 0,
    y = 0,
    dx = 2,
    phase = 1,
    value = 1000,
    isDead = false
}

g_ufoAnimPhases = {
    64, 80, -2,    -- basic movement
    66, 82, nil,   -- death
}

function Ufo:new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    -- init properties
    obj.y = 2
    if flr(rnd(2)) % 2 == 0 then
        obj.x = 128
        obj.dx = -(rnd(1.2) + 0.3)
    else
        obj.x = -16
        obj.dx = rnd(1.2) + 0.3
    end

    -- play sound effects when ufo exists
    sfx(Sfx.UfoMove, 2)

    return obj
end

function Ufo:tick()
    if self.phase >= 0 then
        -- update animation phase
        self.phase += 1
        if g_ufoAnimPhases[self.phase] == nil then
            self.phase = -1    
        elseif g_ufoAnimPhases[self.phase] < 0 then
            self.phase += g_ufoAnimPhases[self.phase]
        end
    end
end

function Ufo:draw()
    if self.phase >= 0 then
        spr(g_ufoAnimPhases[self.phase], self.x, self.y, 2, 1)
    end
end

function Ufo:move()
    self.x += self.dx
end

function Ufo:isOffScreen()
    return self.x < -16 or self.x > 128
end

function Ufo:collide(x, y)
    if self.isDead then
        return false
    end

    return x >= self.x and x <= self.x + 16
        and y >= self.y and y <= self.y + 8
end

function Ufo:hide()
    sfx(-1, 2) -- stop ufo sound
end

function Ufo:kill()
    if self.isDead then
        return
    end

    sfx(-1, 2) -- stop ufo sound
    sfx(Sfx.UfoExplode)

    self.isDead = true
    self.phase = 4 -- switch to exploding animation phase
end