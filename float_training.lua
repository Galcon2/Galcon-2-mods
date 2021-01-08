function init()
    OPTS = {
        sw = 480,
        sh = 320,
        home_prod = 100,
        home_ships = 100,  
        float_prod = 15,
        player_neutrals = 13,
        float_neutrals = 6,
        float_shipcount = 25,
    }

    -- COLORSORDER[2,13] = {"BLUE","RED","YELLOW","CYAN","WHITE","ORANGE","MINT","SALMON","PURPLE","PINK","PERIWINKLE","GREEN"}
    COLORS = {0x555555, -- gray
        0x0000ff,0xff0000,
        0xffff00,0x00ffff,
        0xffffff,0xffbb00,
        0x99ff99,0xff9999,
        0xbb00ff,0xff88ff,
        0x9999ff,0x00ff00,
    }
    spawnside = "LEFT" or "RIGHT" -- add spawn sides
    floatscore = 0
    
    init_game()
end

function init_game()
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)
    --create users
    player = g2.new_user("player", COLORS[3])
    g2.player = player

    neutral_player = g2.new_user("neutral", COLORS[1])
    neutral_player.ships_production_enabled = false

    local midmargin = OPTS.sw/8 --create space
    -- SPAWN PLANETS
    -- spawn player neutrals
    for i=1, OPTS.player_neutrals do
        local x = math.random(0, OPTS.sw/2 - midmargin)
        local y = math.random()*OPTS.sh
        local player_neutral_prod = math.random(15,100)
        local player_neutral_cost = math.random(0, 30)
        g2.new_planet(neutral_player, x, y, player_neutral_prod, player_neutral_cost)
    end
    --spawn float neutrals
    for i=1, OPTS.float_neutrals do
        local x = math.random(OPTS.sw/2 + midmargin*2, OPTS.sw)
        local y1 = math.random(0, OPTS.sh/2 - midmargin/1.5)
        local y2 = math.random(OPTS.sh/2 + midmargin/1.5, OPTS.sh)
        local range = {y1, y2}
        local y = range[math.random(1, #range)]
        local float_neutral_prod = 0
        local float_neutral_cost = 0
        --make sure a planet spawn on either side of OPTS.sh
        if i == 1 then
            y = y1
        elseif i == 2 then
            y = y2
        end

        planets1 = g2.new_planet(neutral_player, x, y, float_neutral_prod, float_neutral_cost)
    end
    --spawn player_home
    local home_x = math.random(0, OPTS.sw/2 - midmargin*4)
    local home_y = math.random()*OPTS.sh
    g2.new_planet(player, home_x, home_y, OPTS.home_prod, OPTS.home_ships)

    g2.planets_settle(0, 0, OPTS.sw, OPTS.sh)
    -- SPAWN FLOAT FLEET
    local planets = g2.search("neutral")
    for i, o in pairs(planets) do
        if o.ships_production == 0 then
            if i == 1 then
                -- g2.new_fleet(player, OPTS.float_shipcount, from self, to any player_neutral)
            end
        end
    end
end

function loop(t)
end

function event(e)

end

--[[UTILITY FUNCTIONS]]--
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end