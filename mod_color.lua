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

    colorlog = {}
    coloravg = {}
    alltimes = {}

    counter = 0
    samplesize = 0
    totalavg = 0

    start_menu()
end
 
function init_game()
    OPTS.time = 0
    g2.game_reset()
    g2.state = "play"
    g2.view_set(0, 0, OPTS.sw, OPTS.sh)

    neutral_player = g2.new_user("", COLORS[math.random(2,#COLORS)])
    g2.player = neutral_player
    neutral_player.ships_production_enabled = false
    neutral_player.title_value = nil
    --spawn planet of certain color anywhere on screen within bounds
    local marginW = 15
    local marginH = 10
    local x = math.random(OPTS.sw/marginW,OPTS.sw/marginW*(marginW-1))
    local y = math.random(OPTS.sh/marginH,OPTS.sh/marginH*(marginH-1))

    g2.new_planet(neutral_player, x, y, 100, 100)
end
--put all times in list of corresponding color
function appendColorlog()
    for i=2, #COLORS do
        if neutral_player.render_color == COLORS[i] then
            if colorlog[i-1] == nil then
                colorlog[i-1] = {string.format("%f", OPTS.time)}
                colori = colorlog[i-1]
                avgColori()
            else
                table.insert(colori, string.format("%f", OPTS.time))
                avgColori()
            end
        end
    end
end
--take average of every color i
function avgColori()
    local sum, avg = 0
    for i=1, #colori do
        sum = sum + colori[i]
    end
    avg = sum / #colori
    for i=1, #COLORS do
        if neutral_player.render_color == COLORS[i] then
            coloravg[i-1] = avg
        end
    end
end
-- take total average of all times
function calculatetTotalavg()
    local sum, avg = 0
    table.insert(alltimes, string.format("%f", OPTS.time))
    for i=1, #alltimes do
        sum = sum + alltimes[i]
    end
    avg = sum / #alltimes
    totalavg = avg
end

function fixColoravgDisplay()
    for i=2, #COLORS do
        if coloravg[i-1] == nil then
            coloravg[i-1] = 0
        end
    end
end

function loop(t)
    OPTS.time = OPTS.time + t
    local neutral_planet = g2.search("planet owner:")
    local home = neutral_planet[1]
    if home:selected() and not isStarted then
        samplesize = samplesize + 1
        OPTS.isStarted = true
        home:destroy(); g2.play_sound("sfx-explode.wav") --destroy planet on click 
        appendColorlog()
        calculatetTotalavg()
        score_menu()
        g2.state ="pause"
    end
    
    counter = 0
end

function event(e)
    if e.type == "pause" then
        g2.state = "pause"
        g2.html = "<table><tr><td><input type='button' value='Resume' onclick='resume' />"
    end
    if e.type == "onclick" and e.value == "resume" then
        g2.state = "play"
    end
    if e.type == "onclick" and e.value == "next" then
        g2.state = "play"
        init_game()
    end
end

function start_menu()
    g2.html = ""..
    "<table>"..
    "<tr><td><h1>Color reaction speed test</h1>"..
    "<tr><td><p>Click the planets as fast as possible.</p>"..
    "<tr><td><p>Larger sample size means more accurate results. (>100 recommended)</p>"..
    "<tr><td>"..
    "<tr><td><input type='button' value='Start' onclick='next' />"..
    "";
end

function score_menu()
    fixColoravgDisplay()
 g2.html = ""..
    "<table>"..
    "<tr><td><h1>Good Job!</h1>"..
    "<tr><td><p>Time: ".. string.format("%f", OPTS.time) .." seconds</p>"..
    "<tr><td><p>Sample size: ".. samplesize .."</p>"..
    "<tr><td>"..
    "<tr><td><p>Blue average: ".. coloravg[1] .." seconds</p>"..
    "<tr><td><p>Red average: ".. coloravg[2] .." seconds</p>"..
    "<tr><td><p>Yellow average: ".. coloravg[3] .." seconds</p>"..
    "<tr><td><p>Cyan average: ".. coloravg[4] .." seconds</p>"..
    "<tr><td><p>White average: ".. coloravg[5] .." seconds</p>"..
    "<tr><td><p>Orange average: ".. coloravg[6] .." seconds</p>"..
    "<tr><td><p>Mint average: ".. coloravg[7] .." seconds</p>"..
    "<tr><td><p>Salmon average: ".. coloravg[8] .." seconds</p>"..
    "<tr><td><p>Purple average: ".. coloravg[9] .." seconds</p>"..
    "<tr><td><p>Pink average: ".. coloravg[10] .." seconds</p>"..
    "<tr><td><p>Periwinkle average: ".. coloravg[11] .." seconds</p>"..
    "<tr><td><p>Green average: ".. coloravg[12] .." seconds</p>"..
    "<tr><td>"..
    "<tr><td><p>Total average: ".. string.format("%f", totalavg) .." seconds</p>"..
    "<tr><td>"..
    "<tr><td><input type='button' value='Next' onclick='next' />"..
    "";
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
