function init()
    OPTS = {
        sw = 480,
        sh = 320,
        planets = 256,
        prod = 50,
        cost = 25,
        
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
    planets = {}
    
    init_game()
end

function init_game()
    g2.game_reset()
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)
    g2.state = "play"

    user = g2.new_user("game11", COLORS[1])
    g2.player = user

    home_user = g2.new_user("player1", COLORS[2])

    planet_lock = false
    planet_info_lock = false
    planet_x = 0
    planet_y = 0
    --draw map border
    draw_map_border()
    OPTS.editmode = "default"
    OPTS.usermode = "neutrals"
end

function draw_map_border()
    g2.new_line(0xff0000, 0, 0, OPTS.sw, 0)
	g2.new_line(0xff0000, OPTS.sw, 0, OPTS.sw, OPTS.sh)
	g2.new_line(0xff0000, OPTS.sw, OPTS.sh, 0, OPTS.sh)
	g2.new_line(0xff0000, 0, OPTS.sh, 0, 0)
end

function init_custom_game()
    
end

function loop(t)
    
end

function prodToRadius(p)
    return (p * 12 / 5 + 168) / 17
end

function event(e)
    local prod = OPTS.prod
    local cost = OPTS.cost
    local saved_prod = OPTS.prod
    local saved_cost = OPTS.cost
    

    if e.type == "ui:down" then -- make_new_stuff here or it might bug
        planet = g2.new_planet(user, e.x, e.y, prod, cost)
        planet.ships_production_enabled = false
        planet_x = planet.position_x
        planet_y = planet.position_y
        
        -- spawn planet label (invisible)
        planet_info = g2.new_label("+"..prod, planet_x-2, planet_y+17)
        planet_info.render_color = COLORS [5]
        planet_info.label_font = "font-play"
        planet_info.render_alpha = 0
        planet_info.label_size = 15

        if OPTS.editmode == "symmetry" then
            planetsym = g2.new_planet(user, OPTS.sw-e.x, OPTS.sh-e.y, prod, cost)
            planetsym.ships_production_enabled = false
            planetsym_x = planetsym.position_x
            planetsym_y = planetsym.position_y
        end

        planet_lock = false
        planet_info_lock = false
    end

    if e.type == "ui:motion" and planet_lock == false then
        if planet ~= nil then
            local selected_buffer = 15
            local planet_xr_selected = planet.position_x + planet.planet_r + selected_buffer
            local planet_minus_xr_selected = planet.position_x - planet.planet_r - selected_buffer
            local planet_yr_selected = planet.position_y + planet.planet_r + selected_buffer
            local planet_minus_yr_selected = planet.position_y - planet.planet_r - selected_buffer

            prod = prod -planet_x + e.x
            if prod < 15 then
                prod = 15
            end
            cost = cost -OPTS.sh+planet_y + OPTS.sh-e.y
            if cost < 0 then
                cost = 0
            end
            planet.ships_production = prod
            planet.planet_r = prodToRadius(prod)
            planet.ships_value = cost
            -- make label visible 
            if planet_info_lock == false and e.x > planet_xr_selected or e.x < planet_minus_xr_selected or e.y > planet_yr_selected or e.y < planet_minus_yr_selected then
                    planet_info.render_alpha = 255
                    planet_info_lock = true
            end
            --update planet label
            if planet_info ~= nil then
                planet_info.label_text = "+"..math.floor(prod)
            end

            if OPTS.editmode == "symmetry" then
                planetsym.ships_production = prod
                planetsym.planet_r = prodToRadius(prod)
                planetsym.ships_value = cost
            end
        end
    end
    if e.type == "ui:up" then
        planet_lock = true
        table.insert(planets, planet)
        if OPTS.editmode == "symmetry" then
            table.insert(planets, planetsym)
        end

        if planet_info ~= nil then
            planet_info:destroy()
        end
        if OPTS.usermode == "homes" and planet ~= nil then
            planet:planet_chown(home_user)
            if OPTS.editmode == "symmetry" and planetsym ~= nil then
                planetsym:planet_chown(home_user)
            end
        end
    end
    --pause/edit menu
    if e.type == "pause" then
        g2.state = "pause"
        g2.html = 
            "<table><tr><td><input type='button' value='Resume' onclick='resume' />"..
            "<tr><td><input type='button' value='Asymmetry' onclick='editmode:default' />"..
            "<tr><td><input type='button' value='Symmetry' onclick='editmode:symmetry' />"..
            "<tr><td><input type='button' value='Undo' onclick='editmode:undo' />"..
            "<tr><td><input type='button' value='Homes' onclick='usermode:homes' />"..
            "<tr><td><input type='button' value='Neutrals' onclick='usermode:neutrals' />";
    end
    if e.type == "onclick" and e.value == "resume" then
        g2.state = "play"
    elseif e.type == "onclick" and e.value == "editmode:default" then -- make asym/sym toggle
        g2.state = "play"
        OPTS.editmode = string.sub(e["value"], 10)
    elseif e.type == "onclick" and e.value == "editmode:symmetry" then -- make asym/sym toggle
        g2.state = "play"
        OPTS.editmode = string.sub(e["value"], 10)
    elseif e.type == "onclick" and e.value == "usermode:homes" then 
        g2.state = "play"
        OPTS.usermode = string.sub(e["value"], 10)
    elseif e.type == "onclick" and e.value == "usermode:neutrals" then 
        g2.state = "play"
        OPTS.usermode = string.sub(e["value"], 10)
    elseif e.type == "onclick" and e.value == "editmode:undo" then
        g2.state = "play"
        --undo one
        local last_planet = planets[#planets]
        if OPTS.editmode == "default" and planet ~= nil then
            if last_planet ~= nil then
                last_planet:destroy()
                planets[#planets] = nil
            end
        end
        --undo two
        if OPTS.editmode == "symmetry" then
            if last_planet ~= nil then
                last_planet:destroy()
                planets[#planets] = nil
            end
            last_planet = planets[#planets]
            if last_planet ~= nil then
                last_planet:destroy()
                planets[#planets] = nil
            end
        end
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