player = Player:new(nil)
ufo = nil
aliens = {}
bunkers = {}

aliens_num_rows = 4
aliens_num_cols = 6
aliens_dx = 0
aliens_dy = 0
aliens_low_y = 0
aliens_mul = 1
aliens_move_freq = 10

intro_flip = false

g_ticks = 0
g_level = 1
g_score = 0
g_debug = false

GameStates = {
    Intro = 0,
    GameInit = 1,
    Game = 2,
    LevelComplete = 3,
    GameOver = 4
}

g_state = GameStates.Intro

-- debug

function d_draw()
    if not g_debug then
        return
    end
    
    print(g_ticks, 112, 2, 6)
end

-- game screen

function g_init()
    cls()
    aliens = {}
    player:reset()
    aliens_dx = 0
    aliens_dy = 0
    g_ticks = 0

    g_init_aliens()

    g_init_bunkers()
    -- draw only once on init to keep damage
    for bunker in all(bunkers) do
        bunker:draw()
    end

    -- move to next state
    g_state = GameStates.Game
    g_draw_status_bar()
end

function g_init_aliens()
    aid = 0
    ax = 6
    ay = 12
    
    for i=1,aliens_num_rows do
        ax = 6
        for j=1,aliens_num_cols do
            add(aliens, Alien:new(nil, ax, ay, 50 - (g_level * 2)))
            ax += 20
        end
        ay += 16
    end
end

function g_init_bunkers()
    bx = 8
    for i=1,4 do
        add(bunkers, Bunker:new(nil, bx))
        bx += 32
    end
end

function g_cls()
    rectfill(0, 0, 128, aliens_low_y, 0)
    rectfill(0, 112, 128, 128, 0)
end

function g_draw()
    g_cls()
    for a in all(aliens) do
        a:draw()
    end
    player:draw()
    g_draw_status_bar()
    if ufo != nil then
        ufo:draw()
    end
end

function g_draw_status_bar()
    lx = 2
    for i=1,player.lives do
        spr(36, 2 + (8 * (i - 1)), 120, 1, 1)
    end

    print(g_score, 60, 122)
    print("lEVEL " .. g_level, 96, 122)
end

function g_update()
    if ufo == nil and (flr(rnd(100)) > 98) then
        ufo = Ufo:new(nil)
    end

    g_input()
    g_aliens_update()
    g_player_update()
    g_ufo_update()
    
    if aliens_low_y >= player.y or player.isDead then
        g_game_over()
        return
    end

    for alien in all(aliens) do
        g_score += player:didHit(alien) * (g_level * 0.25)
        alien:didHit(player)
    end
    if ufo != nil then
        g_score += player:didHit(ufo) * (g_level * 0.25)
    end
end

function g_game_over()
    if ufo != nil then
        ufo:hide()
    end
    sfx(Sfx.GameOver)
    g_state = GameStates.GameOver
    player = Player:new(nil) -- create new player after game over
end

function g_player_update()
    if g_ticks % 6 == 0 then
        player:tick()
    end
    player:update()
end

function g_ufo_update()
    if ufo != nil then
        if g_ticks % 6 == 0 then
            ufo:tick()
        end
        ufo:move()
        if ufo:isOffScreen() then
            ufo:hide()
            ufo = nil
        end
    end
end

function g_aliens_update()
    isAllAliensDead = true
    for alien in all(aliens) do
        alien:update()
        if not alien.isDead then
            isAllAliensDead = false
        end
    end

    if isAllAliensDead then
        sfx(Sfx.LevelComplete)
        if ufo != nil then
            ufo:hide()
        end
        g_state = GameStates.LevelComplete
        return
    end

    if g_ticks % aliens_move_freq == 0 then
        aliens_dx += aliens_mul * 1
        if aliens_dx == 8 then
            aliens_mul = -1
            aliens_dy = 2
        elseif aliens_dx == -6 then
            aliens_mul = 1
            aliens_dy = 2
        end

        aliens_low_y = 0
        for alien in all(aliens) do
            alien:tick()
            alien:deltaMove(1 * aliens_mul, aliens_dy)
            aliens_low_y = max(aliens_low_y, alien.y + 16)
        end

        sfx(Sfx.Step)
        aliens_dy = 0
    end
end

function g_input()
    if btn(0) then
        player:moveDelta(-1)
    end
    if btn(1) then
        player:moveDelta(1)
    end
    if btn(5) then
        player:fire()
    end
end

-- intro screen

function intro_draw()
    cls()

    if g_ticks % 16 == 0 then
        intro_flip = not intro_flip
    end
    isFlip = intro_flip

    for i=1,6 do
        if isFlip then
            spr(0, i * 17, 20, 2, 2)
        else
            spr(2, i * 17, 20, 2, 2)
        end
        isFlip = not isFlip
    end

    print("f A K E   i N V A D E R S", 16, 50, 7)
    print("BY MX", 16, 58, 7)
    print("pRESS (X) tO sTART", 16, 78, 7)

    g_score = 0
    g_level = 1
end

function intro_update()
    if btn(5) then
        g_state = GameStates.GameInit
    end
end

-- game over

function go_update()
    if btn(4) then
        g_state = GameStates.Intro
    end
end

function go_draw()
    cls()
    print("g A M E   o V E R !", 16, 50, 7)
    print("fINAL sCORE: " .. g_score, 16, 68, 10)
    print("pRESS (o) tO cONTINUE", 16, 98, 7)
end

-- level completed

function lvl_update()
    if btn(4) then
        g_level += 1
        aliens_move_freq -= 1
        if aliens_move_freq < 2 then
            aliens_move_freq = 2
        end
        g_state = GameStates.GameInit
    end
end

function lvl_draw()
    cls()
    print("l E V E L   c O M P L E T E !", 16, 50, 7)
    print("sCORE: " .. g_score, 16, 68, 10)
    print("pRESS (o) tO cONTINUE", 16, 98, 7)
end

-- game loop

function _init()
    cls()
    clear_log()
end

function _update()
    g_ticks = (g_ticks + 1) % 32767

    if g_state == GameStates.Intro then
        intro_update()
    elseif g_state == GameStates.GameInit then
        g_init()
    elseif g_state == GameStates.Game then
        g_update()
    elseif g_state == GameStates.LevelComplete then
        lvl_update()
    elseif g_state == GameStates.GameOver then
        go_update()
    end
end

function _draw()
    if g_state == GameStates.Intro then
        intro_draw()
    elseif g_state == GameStates.Game then
        g_draw()
    elseif g_state == GameStates.LevelComplete then
        lvl_draw()
    elseif g_state == GameStates.GameOver then
        go_draw()
    end
    d_draw()
end