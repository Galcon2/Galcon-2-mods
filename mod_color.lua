function init()
    OPTS = {
        sw = 480,
        sh = 320,
        isStarted = false,
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

    counter = 0
    colorlog = {}
    init_game()
end
 
function init_game()

    OPTS.time = 0
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)

    neutral_player = g2.new_user("", COLORS[math.random(2,13)])
    g2.player = neutral_player
    neutral_player.ships_production_enabled = false
    neutral_player.title_value = nil
    
    
    --spawn planet of certain color anywhere on screen within bounds
    local x = math.random()*OPTS.sw --add bounds
    local y = math.random()*OPTS.sh
    g2.new_planet(neutral_player, x, y, 100, 100)
end
--put all times in list of corresponding color
function appendColorlog()
    for i=2, #COLORS do
        if neutral_player.render_color == COLORS[i] then
            if colorlog[i-1] == nil then
                colorlog[i-1] = string.format("%f", OPTS.time)
            else
                colorlog[i-1] = {"time1","time2"} --find way to add to already existing tables
            end
            print(dump(colorlog))
        end
    end
end

function loop(t)
    OPTS.time = OPTS.time + t
    local neutral_planet = g2.search("planet owner:")
    local home = neutral_planet[1]
    if home:selected() and not isStarted then
        OPTS.isStarted = true
        home:destroy(); g2.play_sound("sfx-explode.wav") --destroy planet on click 
        score_menu()
        appendColorlog()
        g2.state ="pause"
    end
    
    counter = 0
    --[[ for p in pairs(g2.search("planet -neutral")) do
        counter = counter + 1
    end
 ]]
    --[[ if counter >= 1 then
        score_menu()
        g2.state ="pause"
    end ]]
end

function event(e)
    if e.type == "pause" then
        g2.state = "pause"
        g2.html = "<table><tr><td><input type='button' value='Resume' onclick='resume' />"
    end
    if e.type == "onclick" and e.value == "resume" then
        g2.state = "play"
    end
    if e.type == "onclick" and e.value == "new_game" then
        g2.state = "play"
        init_game()
    end
    if e.type == "onclick" and e.value == "restart" then
        g2.state = "play"
        init_game()
    end

end
 
function init_win()
    g2.state = "pause"
    g2.html = "<table><tr><td><h1>Good job!"..
              "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end
 
function init_lose()
    g2.state = "pause"
    g2.html = "<table><tr><td><h1>Try again?"..
              "<tr><td><input type='button' value='New Game' onclick='new_game' />"
end

function score_menu()
 g2.html = "glide"..
    "<table>"..
    "<tr><td><h1>Good Job!</h1>"..
    "<tr><td><p>Time: " .. string.format("%f", OPTS.time) .. " seconds</p>"..
    "<tr><td>"..
    "<tr><td>"..
    "<tr><td><input type='button' value='Restart' onclick='restart' />"..
    "<tr><td><input type='button' value='Quit' onclick='quit' />"..
    "glide";
  end

-- UTILITY FUNCTIONS
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
