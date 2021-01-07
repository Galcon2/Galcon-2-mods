function init()
    OPTS = {
        sw = 480,
        sh = 320,
        size = 80,
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

    init_game()
end

function init_game()
    OPTS.time = 0
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)

    spawnCircle()
end

function spawnCircle()
    local circlecolor = 0xff0000
    neutral_player = g2.new_user("", circlecolor)
    g2.player = neutral_player
    neutral_player.ships_production_enabled = false
    neutral_player.title_value = nil

    local marginW = 15
    local marginH = 10
    local x = math.random(OPTS.sw/marginW,OPTS.sw/marginW*(marginW-1))
    local y = math.random(OPTS.sh/marginH,OPTS.sh/marginH*(marginH-1))

    local number = 1
    planetradius = prodToRadius(OPTS.size)
    local buffer = 2*planetradius
    circleradius = planetradius + buffer

    g2.new_planet(neutral_player, x, y, OPTS.size, number)
    newcircle = g2.new_circle(circlecolor, x, y, circleradius)

end

function loop(t)
    OPTS.time = OPTS.time + t --make time not depend on fps
    print(math.floor(OPTS.time+0.5))
    --make circle go from transparent to full max alpha
    --make circle approach planet
    if circleradius >= planetradius then
        if OPTS.time >= 0.25 then
            newcircle.draw_r = circleradius-0.25
            circleradius = circleradius-0.25
        end
    end
    --make planet increase in size and decrease in transparency when circleradius >= planetradius until 0 -> destroy object
end

function event(e)

end

function prodToRadius(p)
    return (p*12/5 + 168)/17
end