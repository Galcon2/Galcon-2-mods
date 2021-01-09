-- ideas for additions:
-- faster/increasing speed of floating ships
-- faster/increasing game speed
-- mid line goes closer to right side over time
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
        wait = 0.2
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
    spawnside = "LEFT" or "RIGHT" -- TODO: add spawn sides
    center = {OPTS.sw/2, OPTS.sh/2}
    timer = 0

    start_menu()
end

function init_game()
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)
    
    OPTS.time = 0
    score1 = 0
    score2 = 0
    score = score1 + score2
    --create users
    player = g2.new_user("player", COLORS[2])
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
        local player_neutral_cost = math.random(1, 30)

        player_planet = g2.new_planet(neutral_player, x, y, player_neutral_prod, player_neutral_cost)
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
        --make sure a planet spawns on either side of OPTS.sh
        if i == 1 then
            y = y1
        elseif i == 2 then
            y = y2
        end

        g2.new_planet(neutral_player, x, y, float_neutral_prod, float_neutral_cost)
    end
    --spawn player_home
    local home_x = math.random(0, OPTS.sw/2 - midmargin*4)
    local home_y = math.random()*OPTS.sh
    home = g2.new_planet(player, home_x, home_y, OPTS.home_prod, OPTS.home_ships)
    g2.planets_settle(0, 0, OPTS.sw, OPTS.sh)
    g2.planets_settle()
    --spawn mid line
    g2.new_line(COLORS[3], OPTS.sw/2, 10, OPTS.sw/2, OPTS.sh)
    -- SPAWN FLOAT FLEET
    -- index player_neutrals
    r = {}
    local v = {}

    player_planets = g2.search("planet")
    for i, o in pairs(player_planets) do
        if o.ships_production ~= 0 then 
            table.insert(r, o)
        end
    end
    -- find player_planets cost
    player_planets_cost = {}
    for i=1, #r do
        player_planets_cost[i] = r[i].ships_value
    end
    -- index float_neutrals
    local v = {}
    local float_planets = g2.search("planet")
    for i, o in pairs(float_planets) do
        if o.ships_production == 0 then
            table.insert(v, o)
        end
    end
    -- index player owned player_neutrals HOW?
    -- spawn float fleet
    float_fleet = g2.new_fleet(player, OPTS.float_shipcount, v[math.random(1, #v)], r[math.random(1, #r)]) --send from self to random player_neutral
    -- REINFORCE REINFORCE_PLANET
    -- TODO1: find player_neutral with closest distance to center
    local centerdot = g2.new_line(COLORS[1], OPTS.sw/2, OPTS.sh/2, OPTS.sw/2, OPTS.sh/2)
    reinforceplanet = 0
    local distancetomid = {}
    for i, o in pairs(r) do
        distmid = (g2.distance(r[i], centerdot))
        table.insert(distancetomid, distmid)
    end
    -- put circle/outline "planet-aura-s24.png" around reinforce planet instead of green circle
    reinforceplanet = r[math.random(1,#r)] -- UNFINISHED TODO1*
    reinforceplanet_cost = reinforceplanet.ships_value
    local planetradius = prodToRadius(reinforceplanet.ships_production)
    local radiusbuffer = 5

    local reinforcecircle = g2.new_circle(COLORS[13], reinforceplanet.position_x, reinforceplanet.position_y, planetradius + radiusbuffer)
    -- create score_label
    score_label = g2.new_label("Score: "..score, OPTS.sw, 0)
    -- create timer_label
    timer_label = g2.new_label("Time: ".. timer, OPTS.sw/2, 0)
end

function prodToRadius(p)
    return (p*12/5 + 168)/17
end
--[[GAME LOOP]]--
function loop(t)
    OPTS.time = OPTS.time + t
    -- pause/end game if float fleet lands ANYWHERE
    if float_fleet.fleet_ships < OPTS.float_shipcount then
        game_over()
    end
    local approx_float_fleet_r = OPTS.sw/16
    if float_fleet.position_x < OPTS.sw/2 + approx_float_fleet_r then
        game_over()
    end
    update_score()
    displayTimer()
    timer = math.floor(OPTS.time+0.5)
end

function update_score()
    score = math.floor(score1 * score2 +0.5)
    
    if reinforceplanet.ships_value > reinforceplanet_cost then 
        reinforceplanet_cost = reinforceplanet_cost + 1
        score1 = reinforceplanet_cost
    end

    for i=1, #r do
        if r[i].ships_value < 1 then --cheated with shift spam
            score2 = score2 + 0.001
        end
    end
    if score ~= 0 then 
        score_label.label_text = "Score: "..score
    end
end

function displayTimer()
    if math.floor(OPTS.time+0.5) > 0 then
        timer_label.label_text = "Time: "..timer
    end
end
--[[HTML]]--
function start_menu()
    g2.html = ""..
    "<table>"..
    "<tr><td><h1>Float training</h1>"..
    "<tr><td>"..
    "<tr><td><p>Don't let your float fleet hit planets or the red line in the middle.</p>"..
    "<tr><td><p>Score points by feeding ships to the planet with a green circle with 100% of your ships.</p>"..
    "<tr><td>"..
    "<tr><td><input type='button' value='Start' onclick='restart' />"..
    "";
end

function game_over()
    g2.html = ""..
    "<table>"..
    "<tr><td><h1>Game over!</h1>"..
    "<tr><td></tr></td>"..
    "<tr><td><p>Time survived: ".. math.floor(OPTS.time+0.5) .." seconds</p></td></tr>"..
    "<tr><td><p>Score: ".. score .." points</p></td></tr>"..
    "<tr><td></tr></td>"..
    "<table><tr><td><input type='button' value='Restart' onclick='restart' />"..
    "";
    g2.state = "pause"
end
--[[EVENTS]]
function event(e)
    if e.type == "pause" then
        g2.state = "pause"
        g2.html = "<table><tr><td><input type='button' value='Resume' onclick='resume' />"
    end
    if e.type == "onclick" and e.value == "resume" then
        g2.state = "play"
    end
    if e.type == "onclick" and e.value == "restart" then
        g2.state = "play"
        init_game()
    end
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
