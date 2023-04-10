g_alienAnimPhases = {
    0, 2, -2,               -- basic movement
    4, 6, 8, 10, 12, nil,   -- death
    38, 38, 40, 40, -13     -- celebration
}

Alien = {
    x = 0,
    y = 0,
    phase = 1,
    projectiles = {},
    fireTicks = 0,
    fireInterval = 50,
    nextFireTicks = 0,
    isDead = false,
    value = 100
}

function Alien:new(obj, x, y, fireInterval)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    -- cap fire interval
    if fireInterval < 10 then
        fireInterval = 10
    end

    -- init properties
    obj.x = x
    obj.y = y
    obj.phase = 1
    obj.projectiles = {}
    obj.fireTicks = 0
    obj.fireInterval = fireInterval or 50
    obj.nextFireTicks = rnd(obj.fireInterval)
    obj.isDead = false

    return obj
end

function Alien:draw()
    if self.phase >= 0 then
        spr(g_alienAnimPhases[self.phase], self.x, self.y, 2, 2)
    end
    for projectile in all(self.projectiles) do
        projectile:draw()
    end
end

function Alien:deltaMove(dx, dy)
    self.x += dx
    self.y += dy
end

function Alien:update()
    -- update projectiles
    for projectile in all(self.projectiles) do
        projectile:draw(0)
        projectile:moveDelta(1)
        projectile:checkHit(1)
        if projectile:isOffScreen() then
            del(self.projectiles, projectile)
        end
    end
end

function Alien:tick()
    if self.phase >= 0 then
        -- update animation phase
        self.phase += 1
        if g_alienAnimPhases[self.phase] == nil then
            self.phase = -1    
        elseif g_alienAnimPhases[self.phase] < 0 then
            self.phase += g_alienAnimPhases[self.phase]
        end
    end

    if not self.isDead then
        -- update fire ticks and check, if should fire
        self.fireTicks += 1
        if self.fireTicks >= self.nextFireTicks then
            add(self.projectiles, Projectile:new(nil, self.x + 8, self.y + 18))
            self.nextFireTicks = rnd(self.fireInterval)
            self.fireTicks = 0
        end
    end
end

function Alien:collide(x, y)
    if self.isDead then
        return false
    end

    return x >= self.x and x <= self.x + 16
        and y >= self.y and y <= self.y + 16
end

function Alien:didHit(player)
    for projectile in all(self.projectiles) do
        if projectile.isHit then
            if player:collide(projectile.x, projectile.y) then
                player:kill()
                del(self.projectiles, projectile)
                self.phase = 10
                return true
            elseif projectile:isInBunkerRegion() then
                -- projectile hit the bunker (probably)
                projectile:draw(0, 2, 2)
                del(self.projectiles, projectile)
            end
        end
    end

    return false
end

function Alien:kill()
    if self.isDead then
        return
    end

    sfx(Sfx.AlienExplode)

    self.isDead = true
    self.phase = 4 -- switch to exploding animation phase
end