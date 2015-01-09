local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local thisIsSceneGroup
local json = require("json")
local saveGameFilePath = system.pathForFile( "savedGame.json", system.DocumentsDirectory )

local stoneSnd = audio.loadSound( "stone_single.wav") -- stone_single
local stonesSnd = audio.loadSound( "stone_group.wav")
local soundPlaying = false 
local backgroundMusic = audio.loadStream( "background_konyl.wav" )

local gameSettings = composer.getVariable("gameSettings")
local skin = gameSettings.skin
local lunka = {}
local LK = {}
local p1turn = true
local isNewGame = composer.getVariable("newGame")
local selectedLunka = 0
local backgroundMusicVolume = 0.8

local stoneSpeed = 300
local delayToMoveToKazan = 300

local lunkaHeight = 140
local lunkaWidth = 94
local ballSize = 30
local kazan = {}
local counter = {} 
local color = { {0.3, 0.36, 0.91},
                {1,1,1}}
local colorIndex = 1
local stones = {}
local totalStones = {}
local gameOver = false
local arraySavingStates = {}
local counterForArray = 1
local numbersOfTurn = 1
local dataToLoadFromGameOver = {}
local whichTurn = 0

local function onKeyEvent(event)
    if (event.keyName == "back") then
        local platformName = system.getInfo( "platformName" )
        if ( platformName == "Android" ) then
            composer.gotoScene( "menu")
            return false
        end
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end

local function podsvetit(player)
    -- 1 from 1 to 9
    -- 2 from 10 to 18
    local start = (player*9)-8
    for i=start, start+8 do
        lunka[i].alpha = 0.5
    end
end

local function otsvetit(player)
    -- 1 from 1 to 9
    -- 2 from 10 to 18
    local start = (player*9)-8
    for i=start, start+8 do
        lunka[i].alpha = 1
    end
end

local function soundFinished(event)
    
    soundPlaying = true
    if (event.completed) then
        soundPlaying = false
    end
end



local function saveState()
    -- body
    local contents
    local savedData = {}
    print("Saving game state")
    fileHandle = io.open( saveGameFilePath,"w" )
    for i =1,18 do
        savedData[i]=counter[i].text
    end
    savedData.player1 = counter.player1.text
    savedData.player2 = counter.player2.text
    savedData.tuzdyk1 = tuzdyk1
    savedData.tuzdyk2 = tuzdyk2
    savedData.p1turn = p1turn
    savedData.totalStones1 = totalStones[1]
    savedData.totalStones2 = totalStones[2]
    contents = json.encode(savedData)
    -- arraySavingStates[#arraySavingStates+1] = contents
    
    -- print("printing array")
    -- for k, v in pairs( arraySavingStates ) do
    -- print(k, v)
    -- end
   
    fileHandle:write(contents)
    io.close(fileHandle)
end

local function returnImage(image_name)
    local str = "images/"..skin.."_style/"..image_name
    return display.newImage(str)
end

local function addScore( num, i )
    -- adds num (number)
    --print("Adding score "..num.." to "..i)
    local temp = 0
    if i==1 then
        temp = counter.player1.text
        temp = temp+num
        counter.player1.text = temp
    elseif i==2 then
        temp = counter.player2.text
        temp = temp+num
        counter.player2.text = temp
    end
end

local function setScore(i, num)
    if i==1 then
        counter.player1.text = num
    elseif i==2 then
        counter.player2.text = num
    end
end

local function handleBackBtn(event)
    -- body
    if (event.phase == "ended") then
        saveState() -- saving game state for 9 kumalak

        local options =
        {
            isModal = true,
            effect = "fade",
            time = 400,
            params = {
                state = "pause"
            }
        }

        composer.showOverlay("gameOver", options)
    end
end

local function setKamni(lunkaId, num)
    
    counter[lunkaId].text = num
end

local function addKamni(lunkaId, num)
    local sum = counter[lunkaId].text+0
    sum = sum + num
    counter[lunkaId].text = sum
end

local function isEven(lunkaId)
    --print("Checking if "..counter[lunkaId].text .." is even")
    local num = counter[lunkaId].text+0
    if num % 2 == 0 then
        return true
    else
        return false
    end
end

local function moveStone(stoneId,origin,dest)
    -- stone init
    local ballX,ballY,ballPos,rowY,rowX
    local j = dest
    local params
    local startingPlayer = 1
    local subtract = false
    if origin>9 then startingPlayer = 2 end
    if dest>9 and startingPlayer==1 then subtract = true
        elseif dest<10 and startingPlayer==2 then subtract = true end
    rowX = 0
    rowY = 0

    if j>9 then
        j=10-(dest-9)
    end
    
    if origin==dest then return true end

    ballPos = #LK[dest]+1
    if ballPos > 58 then
        rowY = 0
        rowX = 0
        ballPos = ballPos - 58
    elseif ballPos > 29 then
        rowY = 0
        rowX = 0
        ballPos = ballPos - 29
    end

    if ballPos>24 then
        rowY = 60
        rowX = 15
        ballPos = ballPos - 24
    elseif ballPos>19 then
        rowY = -20
        rowX = 15
        ballPos = ballPos - 19
    elseif ballPos>12 then
        rowY = 20
        rowX = -15
        ballPos = ballPos - 12
    elseif ballPos>6 then
        rowY = 40
        rowX = 0
        ballPos = ballPos - 6
    end
    ballX = (lunkaWidth/2)+ballSize*(ballPos-1)
    ballY = (lunkaWidth+10)*j +80
    if dest>9 then
        ballX = display.contentWidth-ballX-10
        rowX = -rowX
    else
        ballX = ballX + 10
    end

    --print("moving stone "..stoneId.." to x "..(ballX+rowX).." and y "..ballY+rowY)
    params = {
                time = stoneSpeed,
                x = ballX+rowX,
                y = ballY+rowY
            }

    if origin==0 then
        transition.to(stones[stoneId],params)
        table.insert(LK[dest],#LK[dest]+1,stoneId)
    -- stone from origin
    else
        table.remove(LK[origin])
        transition.to(stones[stoneId],params)
        table.insert(LK[dest],#LK[dest]+1,stoneId)
        if subtract then 
            totalStones[startingPlayer]=totalStones[startingPlayer]-1
            totalStones[3-startingPlayer] = totalStones[3-startingPlayer]+1
            --print("subtracting stone from player "..startingPlayer)
        end
    end
end

local function moveStoneToKazan(tekStone,k)
    --local currentStones = counter[].text
    local currentKazan
    local kazanX, kazanY, rowY, rowX, kazanPos
    local stonesInKazan
    local shifted = false
    if k==1 then 
        kazanX = display.contentCenterX - 30
        currentKazan = 19
        stonesInKazan = counter.player1.text
    elseif k==2 then 
        currentKazan = 20
        kazanX = display.contentCenterX + 30
        stonesInKazan = counter.player2.text
    end
    kazanY = 180
    rowX = 0
    shifted = false

    rowY = #LK[currentKazan]+0
    --print("rowY "..rowY)
        if rowY>58 then
            rowY = rowY - 58
            if rowX==-15 then rowX = 15 end
            if not shifted then
                rowX = rowX + 15
                shifted = true
            end
        elseif rowY>29 then
            
            rowY = rowY - 29
            if not shifted then
                rowX = rowX - 15
                shifted = true
            end
        end
        rowY = rowY * 30
        if shifted then 
            rowY = rowY - 15 
        end
        local params = {
            time = stoneSpeed,
            x = kazanX+rowX,
            y = kazanY+rowY,
            delay = delayToMoveToKazan
        }

        -- set stonePosition to the last id
        --stonePosition = currentStones-i+1 -- last stone in group
        --print("moving stone "..tekStone.." to kazan "..currentKazan.." to x "..params.x.." and y "..params.y)
        transition.moveTo( stones[tekStone], params)
        local pos = #LK[currentKazan]
        if pos==nil then pos = 0 end
        table.insert( LK[currentKazan], pos+1, tekStone ) 
end

local function moveToKazan(lunkaId,k)
    -- move all stones from lunkaId to kazan of player k
    local currentStones = counter[lunkaId].text -- get # of stones in lunka
    local tekStone  -- temp vars for movement
    --local stonePosition -- temp vars for movement
    local currentKazan -- current kazan id for counters
    -- x and y vars for movement of iamge
    local kazanX, kazanY, rowY, rowX, kazanPos
    local stonesInKazan
    local shifted = false
    local currentPlayer = 1

    if lunkaId>9 then currentPlayer =2 end

    if k==1 then 
        kazanX = display.contentCenterX - 30
        currentKazan = 19
        stonesInKazan = counter.player1.text
    elseif k==2 then 
        currentKazan = 20
        kazanX = display.contentCenterX + 30
        stonesInKazan = counter.player2.text
    end
    kazanY = 180
    rowX = 0
    setKamni(lunkaId,0)
    --print("Adding to kazan "..currentStones.." for player "..k)
    addScore(currentStones,k) -- set counter text to 0
    shifted = false
    -- loop through all the stones in lunka
    for i = 1, currentStones do
        --shifted=false
        -- set movement params using x and y vars defined above
        rowY = stonesInKazan+i-1
        if rowY>58 then
            rowY = rowY - 58
            if rowX==-15 then rowX = 15 end
            if not shifted then
                rowX = rowX + 15
                shifted = true
            end
        elseif rowY>29 then
            
            rowY = rowY - 29
            if not shifted then
                rowX = rowX - 15
                shifted = true
            end
        end
        rowY = rowY * 30
        if shifted then 
            rowY = rowY - 15 
        end
        local params = {
            time = stoneSpeed,
            x = kazanX+rowX,
            y = kazanY+rowY,
            delay = delayToMoveToKazan
        }

        -- set stonePosition to the last id
        --stonePosition = currentStones-i+1 -- last stone in group
        
        tekStone = stones[ LK[lunkaId][#LK[lunkaId]]].id -- getting last stone ID in LK[lunkaId]
        
        table.remove( LK[lunkaId])
 
        transition.moveTo( stones[tekStone], params)
        local pos = #LK[currentKazan]
        if pos==nil then pos = 0 end
        table.insert( LK[currentKazan], pos+1, tekStone )     
    end
    --print("getting "..currentStones.." from player "..currentPlayer)
    totalStones[currentPlayer]=totalStones[currentPlayer]-currentStones
end

local function returnPlayerTuzdyk(tuzdyk)
    local player = 0
    if tuzdyk1==tuzdyk then
        player = 1
    elseif tuzdyk2 == tuzdyk then
        player = 2
    end
    return player
end

local function isTuzdyk(lunkaId)

    return (lunkaId==tuzdyk1 or tuzdyk2==lunkaId)
end

------------------Yesa
local function saveTurnsContainer()
    local contents
    local savedData = {}
    whichTurn = whichTurn + 1
    print("Saving turns on game"..#arraySavingStates+1  )
    -- fileHandle = io.open( saveGameFilePath,"w" )
    for i =1,18 do
        savedData[i]=counter[i].text
    end
    savedData.player1 = counter.player1.text
    savedData.player2 = counter.player2.text
    savedData.tuzdyk1 = tuzdyk1
    savedData.tuzdyk2 = tuzdyk2
    savedData.p1turn = p1turn
    savedData.totalStones1 = totalStones[1]
    savedData.totalStones2 = totalStones[2]
    contents = json.encode(savedData)
    --arraySavingStates[#arraySavingStates+1] = contents

    arraySavingStates[whichTurn] = contents
    print("which turn on increment:"..whichTurn)
    
    
    
    -- print("printing array")
    -- for k, v in pairs( arraySavingStates ) do
    -- print(k, v)
    -- end
end
--------------------------------

local function makeTurn(lunkaId)
    local startingPlayer = 1
    local opposingPlayer = 2
    local stealStones = false -- proverka nado li perekidyvat kamni v kazan
    local currentStones = counter[lunkaId].text+0 -- skolko kamnei v lunke
    local nextLunkaId = lunkaId+1
    local lastLunkaId = nextLunkaId
    local continue = true

    if lunkaId>9 then 
        startingPlayer = 2 
        opposingPlayer = 1
    end

   
    ----------- setting counter turn back to 1  
    numbersOfTurn = 1

    
    print("I'm in MakeTurn")
    if totalStones[startingPlayer] == 0 then 
        --print("got here!")
        local winnerLoc = 3-startingPlayer
        if counter.player1.text+0>81 then 
            winnerLoc=1
        elseif counter.player2.text+0>81 then 
            winnerLoc=2
        end
        
        local options =
        {
            isModal = true,
            effect = "fade",
            time = 400,
            params = {
                state = "atsyz",
                winner = winnerLoc
            }
        }

        composer.showOverlay("gameOver", options)
    end
    if currentStones==0 then
        return true
    elseif currentStones==1 then
        if soundPlaying == false then
                audio.play(stoneSnd,{ onComplete=soundFinished })
            end
        if nextLunkaId>18 then 
            nextLunkaId = 1 
            lastLunkaId = nextLunkaId
        end

        if (nextLunkaId==10) or (nextLunkaId==1) then 
            stealStones = not stealStones 
        end
        
        setKamni(lunkaId,0)
        addKamni(nextLunkaId,1)

        moveStone(LK[lunkaId][1],lunkaId,nextLunkaId)

        if nextLunkaId==tuzdyk1 then
            moveToKazan(nextLunkaId,1)
        elseif nextLunkaId==tuzdyk2 then
            moveToKazan(nextLunkaId,2)
        end
        
        if stealStones then
            print("I'm here! I can steal stones!!")
            if isEven(lastLunkaId) then
                print("I'm here! Its even!!!")
                moveToKazan(lastLunkaId,startingPlayer)
            end
            if (counter[lastLunkaId].text=="3")or(counter[lastLunkaId].text==3) then
                print("here could be tuzdyk")
                if startingPlayer==1 and tuzdyk1=="0"
                    and tuzdyk2~=(10-(lastLunkaId-9)) and (lastLunkaId~=9) and (lastLunkaId~=18) then
                    print("Tuzdyk")
                    tuzdyk1 = lastLunkaId
                
                    ----------------------
                elseif startingPlayer==2 and tuzdyk2=="0"
                    and lastLunkaId~=(10-(tuzdyk1-9))  and (lastLunkaId~=9) and (lastLunkaId~=18) then
                    print("Tuzdyk")
                    tuzdyk2 = lastLunkaId

                    ----------------------
                else
                    print("not tuzdyk because "..startingPlayer.." is startingPlayer and tuzdyk1 "..tuzdyk1.." and tuzdyk2 "..tuzdyk2)
                    continue = false
                end
                if continue then 
                    print("Tuzdyk")
                    thisIsSceneGroup:remove(lunka[lastLunkaId])
                    lunka[lastLunkaId] = returnImage("tuzdyk.png")


                    local yL = (lunkaWidth+10)*lastLunkaId+100
                    local xL = lunkaHeight
                    if startingPlayer==1 then 
                        yL = (lunkaWidth+10)*(18-lastLunkaId+1) +100
                        xL = display.contentWidth - lunkaHeight
                    end

                    lunka[lastLunkaId].y = yL
                    lunka[lastLunkaId].x = xL

                    thisIsSceneGroup:insert(lunka[lastLunkaId])
                    moveToKazan(lastLunkaId,startingPlayer)
                end
            end
        end

    elseif currentStones > 1 then
        if soundPlaying == false then
                audio.play(stonesSnd,{ onComplete=soundFinished })
            end
        setKamni(lunkaId,1)

        for i=1, currentStones - 1 do 
            if nextLunkaId>18 then 
                nextLunkaId = 1 
                lastLunkaId = nextLunkaId
            end
            --print("lunka id = "..nextLunkaId)
            if (nextLunkaId==10) or (nextLunkaId==1) then 
                stealStones = not stealStones 
            end
            
            local tekStone = LK[lunkaId][#LK[lunkaId]]
            --print("Moving stone "..tekStone.." from "..lunkaId.." to "..nextLunkaId)
            moveStone(tekStone, lunkaId, nextLunkaId)
            addKamni(nextLunkaId,1)
            if isTuzdyk(nextLunkaId) then
                moveToKazan(nextLunkaId,returnPlayerTuzdyk(nextLunkaId))
            end
            lastLunkaId = nextLunkaId
            nextLunkaId = nextLunkaId+1
        end

        if stealStones then
            print("I'm here! I can steal stones!!")
            print("last lunka id is "..lastLunkaId)
            print("total stones in lunka is "..counter[lastLunkaId].text)
            if isEven(lastLunkaId) then
                print("Look! Its even!")
                moveToKazan(lastLunkaId,startingPlayer)
            end
            if (counter[lastLunkaId].text=="3")or(counter[lastLunkaId].text==3) then
                
                continue = true
                if (startingPlayer==1) and ((tuzdyk1=="0") or (tuzdyk1==0))
                    and tostring(tuzdyk2)~=tostring(lastLunkaId-9) and (lastLunkaId~=9) and (lastLunkaId~=18) 
                    then
                    
                    tuzdyk1 = lastLunkaId
                    print("Tuzdyk1 = "..lastLunkaId)
                
                    ----------------------
                elseif (startingPlayer==2) and ((tuzdyk2=="0") or (tuzdyk2==0))
                    and tostring(lastLunkaId)~=tostring(tuzdyk1-9)  and (lastLunkaId~=9) and (lastLunkaId~=18) 
                    then
                    
                    tuzdyk2 = lastLunkaId
                    print("Tuzdyk 2 = "..lastLunkaId)
                    ----------------------
                else
                    print("Breaking tuzdyk cycle")
                    print("lastLunkaId = "..lastLunkaId)
                    print("startingPlayer = "..startingPlayer)
                    print("tuzdyk1 "..tuzdyk1.." and tuzdyk2 "..tuzdyk2)
                    continue = false
                end
                if continue then 
                    --thisIsSceneGroup:remove(lunka[lastLunkaId])
                    --print("skin is "..skin)
                    lunka[lastLunkaId] = nil
                    lunka[lastLunkaId] = returnImage("tuzdyk.png")

                    print("Setting tuzdyk image!")
                    local yL = (lunkaWidth+10)*lastLunkaId+100
                    local xL = lunkaHeight
                    if startingPlayer==1 then 
                        yL = (lunkaWidth+10)*(18-lastLunkaId+1) +100
                        xL = display.contentWidth - lunkaHeight
                    end

                    lunka[lastLunkaId].y = yL
                    lunka[lastLunkaId].x = xL

                    thisIsSceneGroup:insert(lunka[lastLunkaId])
                    moveToKazan(lastLunkaId,startingPlayer)
                end
            end
        end

    end
    --print("player 1 has "..totalStones[1].." stones")
    --print("player 2 has "..totalStones[2].." stones")
    --print("End turn")
    p1turn = not p1turn

    if p1turn then
        otsvetit(1)
        podsvetit(2)
    else
        otsvetit(2)
        podsvetit(1)
    end

    if counter.player1.text+0 > 81 then
        local options =
        {
            isModal = true,
            effect = "fade",
            time = 400,
            params = {
                state = "gameOver",
                winner = "1"
            }
        }

        composer.showOverlay("gameOver", options)
    elseif counter.player2.text+0>81 then
        local options =
        {
            isModal = true,
            effect = "fade",
            time = 400,
            params = {
                state = "gameOver",
                winner = "2"
            }
        }

        composer.showOverlay("gameOver", options)
    end

------------------------- saving turns of array
saveTurnsContainer()

--numbersOfTurn = 1

end

local function lunkaClick(event)
    -- body
    local lunkaId = event.target.id

    if event.phase == "ended" then
        --print(event.target.id)
        if (lunkaId<10) and (p1turn) then
            makeTurn(lunkaId)
        elseif (lunkaId>9) and (not p1turn) then
            makeTurn(lunkaId)
        end
    end
end

local function drawBoard(skin, group)
    local audioOptions = {
        channel = 1,
        loops = -1,
        fadein = 1000
    }
    audio.setVolume( backgroundMusicVolume, {channel = 1} )
    audio.play( backgroundMusic, audioOptions)
    --audio.setVolume( 0.1, {channel = 1} )



    if skin~="wood" then colorIndex = 2 end
    local background = returnImage("board.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    group:insert(background)

    local backBtn = widget.newButton{
            top = 5,
            left = 5,
            defaultFile = "images/"..skin.."_style/back_button.png",
            overFile = "images/"..skin.."_style/back_button_over.png",
            onEvent = handleBackBtn
        }
             
        backBtn.x = display.contentCenterX
        backBtn.y = 80
        group:insert(backBtn)

    --local lunka = display.newImage("images/"..skin.."_style/lunka.png")

    for i=1, 9 do
      
        lunka[i]= returnImage("lunka.png")
        lunka[i].x = lunkaHeight
        lunka[i].y = (lunkaWidth + 10)*i +100
        lunka[i].id= i
        group:insert(lunka[i])
        counter[i] = display.newText("0", 10, (lunkaWidth + 10)*i + 100, 
            native.systemFontBold, 30)
        counter[i].x = 20
        --print("setting "..i.." as text field")
        counter[i]:setFillColor(color[colorIndex][1], 
            color[colorIndex][2], color[colorIndex][3])
        counter[i]:rotate(90)
        group:insert(counter[i])

        lunka[i+9] = returnImage("lunka.png")
        lunka[i+9].x = display.contentWidth - lunkaHeight
        lunka[i+9].y = (lunkaWidth + 10)*(10-i) +100
        lunka[i+9].id = i + 9
        group:insert(lunka[i+9])

        counter[i+9] = display.newText("0", display.contentWidth - 10, 
            (lunkaWidth + 10)*(10-i) + 100, 
            native.systemFontBold, 30)
        counter[i+9].x = display.contentWidth - 20
        counter[i+9]:setFillColor(color[colorIndex][1], 
            color[colorIndex][2], color[colorIndex][3])
        counter[i+9]:rotate(-90)
        group:insert(counter[i])
        group:insert(counter[i+9])


        lunka[i]:addEventListener("touch", lunkaClick)

        lunka[i+9]:addEventListener("touch", lunkaClick)
    end
    -- risuem kazans

    kazan[1] = returnImage("kazan.png")
    kazan[1].x = display.contentCenterX - 30
    kazan[1].y = display.contentCenterY + 50
    group:insert(kazan[1])


    kazan[2] = returnImage("kazan.png")
    kazan[2].x = display.contentCenterX + 30
    kazan[2].y = display.contentCenterY + 50
    group:insert(kazan[2])

    counter.player1 = display.newText("0", 80, 124, native.systemFontBold, 30)
    group:insert(counter.player1)

    counter.player1:setFillColor(color[1][1],color[1][2],color[1][3])
    counter.player2 = display.newText("0", display.contentWidth - 80, 124, native.systemFontBold, 30)
    group:insert(counter.player2)
    counter.player2:setFillColor(color[1][1],color[1][2],color[1][3])

    for i=1, 162 do

        stones[i] = returnImage("ball.png")
        stones[i].x = 0
        stones[i].y = 0
        stones[i].id = i
        group:insert(stones[i])

        if (skin ~= "wood") then 
            stones[i].xScale = 0.75
            stones[i].yScale = 0.75
        end
    end   
end

local function cleanBoard(group)
    -- body
    local total = group.numChildren
    --print("total objects "..total)
    for i = 1, total do
        if group[i]~=nil then 
        group[i]:removeSelf()
        end
    end
end

local function initNewGame()
    local data = {}
    local x
    local p1turn

    for i =1,18 do
        data[tostring(i)]="9"
    end
    data["player1"]= "0"
    data["player2"] = "0"
    data["tuzdyk1"] = "0"
    data["tuzdyk2"] = "0"

    x = math.random(2)
    if x==1 then
        p1turn = true
    else
        p1turn = false
    end
    data["p1turn"] = p1turn
    data["totalStones1"] = 81
    data["totalStones2"] = 81

    return data
end

local function loadGame()
    local contents
    local savedData = {}
    --counter = {}
    print("Loading game state")
    fileHandle, errorString  = io.open( saveGameFilePath,"r" )
    if fileHandle then

        local contents = fileHandle:read( "*a" )
        local decoded, pos, msg = json.decode( contents )
        savedData = decoded
        --[[
        print("Printing saved data:")

        for k, v in pairs( savedData ) do
            print(k, v)
        end
        --]]
        for i =1, 18 do
            counter[i].text=decoded[tostring(i)]
            --print("loading saved data lunka "..i.." = "..tostring(decoded[tostring(i)]))
        end
        counter.player1.text = savedData["player1"]
        counter.player2.text = savedData["player2"]
        tuzdyk1 = savedData["tuzdyk1"]
        if tuzdyk1~="0" then
            thisIsSceneGroup:remove(lunka[tuzdyk1])
            lunka[tuzdyk1] = returnImage("tuzdyk.png")
                    
                    
                        yL = (lunkaWidth+10)*(18-tuzdyk1+1) +100
                        xL = display.contentWidth - lunkaHeight
                    

                    lunka[tuzdyk1].y = yL
                    lunka[tuzdyk1].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk1])

        end    
        tuzdyk2 = savedData["tuzdyk2"]
        if tuzdyk2~="0" then
            lunka[tuzdyk2] = nil
                    lunka[tuzdyk2] = returnImage("tuzdyk.png")

                    --print("Setting tuzdyk image!")
                    local yL = (lunkaWidth+10)*tuzdyk2+100
                    local xL = lunkaHeight
                    

                    lunka[tuzdyk2].y = yL
                    lunka[tuzdyk2].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk2])
        end
        p1turn = savedData["p1turn"] 
        totalStones[1]=savedData["totalStones1"]
        totalStones[2]=savedData["totalStones2"]

        fileHandle:write(contents)
    end
    io.close(fileHandle)
    --print("returning saved data from loading = "..savedData)
    return savedData
end



---------------------------------------- Yesa

local function preDecrement_x() 
    whichTurn = whichTurn - 1; 
end

function scene:goBack()
    local contents
    local savedData = {}
    --counter = {}
    -- fileHandle, errorString  = io.open( saveGameFilePath,"r" )
    -- if fileHandle then
   
    
    --local contents = arraySavingStates[whichTurn]

   -- index of array must not be 0, it must be 1 or more

    if (whichTurn > 1) then
       
        preDecrement_x()
        --whichTurn = whichTurn - 1
        print("which turn on decrement:".. whichTurn)
        local contents = arraySavingStates[whichTurn]
        
    -- for k, v in pairs( contents ) do
    -- print(k, v)
    -- end

        local decoded, pos, msg = json.decode( contents )
        savedData = decoded
        dataToLoadFromGameOver = savedData
         
        -- savedData = contents
        -- dataToLoadFromGameOver = contents
        
        
        
        for i =1, 18 do
            counter[i].text=decoded[tostring(i)]
            --print("loading saved data lunka "..i.." = "..tostring(decoded[tostring(i)]))
        end
        counter.player1.text = savedData["player1"]
        counter.player2.text = savedData["player2"]
        tuzdyk1 = savedData["tuzdyk1"]
        if tuzdyk1~="0" then
            thisIsSceneGroup:remove(lunka[tuzdyk1])
            lunka[tuzdyk1] = returnImage("tuzdyk.png")
                    
                    
                        yL = (lunkaWidth+10)*(18-tuzdyk1+1) +100
                        xL = display.contentWidth - lunkaHeight
                    

                    lunka[tuzdyk1].y = yL
                    lunka[tuzdyk1].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk1])

        end    
        tuzdyk2 = savedData["tuzdyk2"]
        if tuzdyk2~="0" then
            lunka[tuzdyk2] = nil
                    lunka[tuzdyk2] = returnImage("tuzdyk.png")

                    --print("Setting tuzdyk image!")
                    local yL = (lunkaWidth+10)*tuzdyk2+100
                    local xL = lunkaHeight
                    

                    lunka[tuzdyk2].y = yL
                    lunka[tuzdyk2].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk2])
        end
        p1turn = savedData["p1turn"] 
        totalStones[1]=savedData["totalStones1"]
        totalStones[2]=savedData["totalStones2"]

        ------------ incrementing numbersofturn back
        numbersOfTurn = numbersOfTurn + 1

       
    
    else 
        dataToLoadFromGameOver = initNewGame()
        return
    end

end


-------------------
local function drawTuzdyk(lastLunkaId)
    thisIsSceneGroup:remove(lunka[lastLunkaId])
    lunka[lastLunkaId] = returnImage("tuzdyk.png")


    local yL = (lunkaWidth+10)*lastLunkaId+100
    local xL = lunkaHeight
    if startingPlayer==1 then 
        yL = (lunkaWidth+10)*(18-lastLunkaId+1) +100
        xL = display.contentWidth - lunkaHeight
    end

    lunka[lastLunkaId].y = yL
    lunka[lastLunkaId].x = xL

    thisIsSceneGroup:insert(lunka[lastLunkaId])
end
----------------------------------------------

local function initBoard(savedData)
    local currentStones = 0
    local lastUsedStone = 0
    local pos = 1
    local data = {}
    local playerIndex = 1
    totalStones[1]=0
    totalStones[2]=0
    data = savedData
    p1turn = data["p1turn"]

    -- print("Printing saved data from initBoard func")

    --     for k, v in pairs( data ) do
    --         printprint(k, v)
    --     end

    if p1turn then
        otsvetit(1)
        podsvetit(2)
    else
        otsvetit(2)
        podsvetit(1)
    end

    for i=1, 18 do
        --pos = 1 
        --print(tostring(data[tostring(i)]))
        counter[i].text = tostring(data[tostring(i)])
        currentStones = tostring(data[tostring(i)])+0

        if i>9 then 
            playerIndex = 2 
        end
        
        totalStones[playerIndex]=currentStones+totalStones[playerIndex]
        --print("setting stones for player "..playerIndex.." = "..totalStones[playerIndex])

        LK[i]={}
        for j=lastUsedStone+1,lastUsedStone+currentStones do
            --print("Moving stone"..stones[j].id.." to lunka #"..i)
            moveStone(j,0,i)

            --pos = pos + 1
        end
        lastUsedStone = lastUsedStone+currentStones
    end
    --print("player 1 kazan = "..data["player1"])
    LK[19]={}
    for i=1,data["player1"] do
        --print("moving stone "..lastUsedStone.." to kazan 1")
        moveStoneToKazan(lastUsedStone,1)
        lastUsedStone = lastUsedStone+1
    end
    LK[20]={}
    for i =1, data["player2"] do
        
        moveStoneToKazan(lastUsedStone,2)
        lastUsedStone = lastUsedStone+1
    end
    counter.player1.text = data["player1"]
    counter.player2.text = data["player2"]
    LK[19] = {}
    LK[20] = {}
    tuzdyk1 = data["tuzdyk1"]+0
    if tuzdyk1>0 then
        drawTuzdyk(tuzdyk1)
    end

    tuzdyk2 = data["tuzdyk2"]+0
    if tuzdyk2>0 then
        drawTuzdyk(tuzdyk2)
    end
    gameOver = false
    --print("Player 1 has "..totalStones[1].." stones")
    --print("Player 2 has "..totalStones[2].." stones")  
end


-------Yesa
local function loadGameFromVar(array)
    -- body

local contents
    local savedData = {}
    --counter = {}
    print("Loading game state from array")
    
        
        savedData = array
        --[[
        print("Printing saved data:")

        for k, v in pairs( savedData ) do
            print(k, v)
        end
        --]]
        for i =1, 18 do
            counter[i].text=tostring(savedData[tostring(i)])
            --print("loading saved data lunka "..i.." = "..tostring(decoded[tostring(i)]))
        end
        counter.player1.text = savedData["player1"]
        counter.player2.text = savedData["player2"]
        tuzdyk1 = savedData["tuzdyk1"]
        if tuzdyk1~="0" then
            thisIsSceneGroup:remove(lunka[tuzdyk1])
            lunka[tuzdyk1] = returnImage("tuzdyk.png")
                    
                    
                        yL = (lunkaWidth+10)*(18-tuzdyk1+1) +100
                        xL = display.contentWidth - lunkaHeight
                    

                    lunka[tuzdyk1].y = yL
                    lunka[tuzdyk1].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk1])

        end    
        tuzdyk2 = savedData["tuzdyk2"]
        if tuzdyk2~="0" then
            lunka[tuzdyk2] = nil
                    lunka[tuzdyk2] = returnImage("tuzdyk.png")

                    --print("Setting tuzdyk image!")
                    local yL = (lunkaWidth+10)*tuzdyk2+100
                    local xL = lunkaHeight
                    

                    lunka[tuzdyk2].y = yL
                    lunka[tuzdyk2].x = xL

                    thisIsSceneGroup:insert(lunka[tuzdyk2])
        end
        p1turn = savedData["p1turn"] 
        totalStones[1]=savedData["totalStones1"]
        totalStones[2]=savedData["totalStones2"]
    
end


--cleaning group fomr other lua

function scene:cleanBoardGameAndLoadNewBoard()
    local sceneGroup = self.view
    local skin = gameSettings.skin
    
    cleanBoard(sceneGroup)
    drawBoard(skin, sceneGroup)
    initBoard(dataToLoadFromGameOver)
    
    -- body
end

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    thisIsSceneGroup = sceneGroup
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase
    local data = {}
    gameSettings = composer.getVariable("gameSettings")
    skin = gameSettings.skin
    isNewGame = composer.getVariable("newGame")

    print("showing multi lua")

    if ( phase == "will" ) then
        --print("Drawing board with skin = "..skin)
        drawBoard(skin, sceneGroup)
        --print("is the game new? "..tostring(isNewGame))
        if not isNewGame then
            print("loading saved game")
            data = loadGame()
        else
            print("starting new game")
            data = initNewGame()
        end

        initBoard(data)

        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
         Runtime:addEventListener( "key", onKeyEvent )
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end



-- "scene:hide()"

function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        print("multiLua var is set")
        saveState()
        cleanBoard(sceneGroup)
        
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end

-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene