-- import libraries
local composer = require( "composer" )
local widget = require ("widget")
local targetLunka, targetAlpha
local gameSettings = composer.getVariable( "gameSettings" )
local skin = gameSettings.skin
local backBtn -- button for iOS to go back to menu
local stoneMoveSpeed = 300 -- how stones move
local lunkaImg = "images/"..skin.."_style/lunka.png" -- path to lunka image
local delayToMoveToKazan = 300 -- how long to wait before moving to kazan

local stoneSnd = audio.loadSound( "stone_group.wav") -- stone_single
local soundPlaying = false -- to avoid sound channel overloading

local scene = composer.newScene(  ) -- get new scene
local gameOverWindow = nil -- window to display loss or victory

local background -- bg for game i.e. board
-- some globals, i know i should use separate file but w/e
local lunkaHeight = 140 
local lunkaWidth = 94
local ballSize = 30
-- some important variables
local totalStones = {} -- counts at every point of game amount of stones, totalStones[1] and totalStones[2]
local lunka = {} -- lunka images
local counter = {} -- text vars for holding counters
local stones = {} -- stone images

local gameOver = false -- check var to see if the game is over
local gameOverText -- var to hold text to display

local kazan = {} -- holds images
local LK = {} -- group of tables, where lk[1] contains stone IDs in lunka 1
local tuzdyk1 = nil -- lunka id with tuzdyk for p1
local tuzdyk2 = nil -- same for p2
local p1turn = true -- turn boolean var to decide who can move

local function showGameOver()
    local options = {
    effect = "fade",
    time = 500,
    isModal = true
    }
    composer.showOverlay( "gameover", options )
end

local function evaluateBoard()

end

local function handleBackBtn(event)
   	if (event.phase == "ended") then
        composer.gotoScene( "menu" )
    end

end

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

local function addScore( i, num )
	-- adds num (number)
    
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
    if temp > 81  then 
        gameOver = true 
        showGameOver()

    elseif totalStones[i]==0 then
    	gameOver = true
        showGameOver()
    end
end

local function setScore(i, num)
    if i==1 then
        counter.player1.text = num
    elseif i==2 then
        counter.player2.text = num
    end
end

local function setKamni(i, num)
	local subt = counter[i].text
    counter[i].text = num
    subt = subt - num

    if i >9 then 
    	totalStones[2]=totalStones[2]-subt
    else 
    	totalStones[1]=totalStones[1]-subt
    end
end

local function addKamni(i, num)
    local sum = counter[i].text
    sum = sum + num
    counter[i].text = sum
    if i>9 then totalStones[2]=totalStones[2]+1
    	else totalStones[1]=totalStones[1]+1 end
end

local function moveStone(stoneId,origin,dest,pos)
	-- move stone from origin to dest and insert stone with id at position pos
    local j2 = dest
    local ballX, ballY, ballPos, rowY, rowX
    
    rowY = 0
    rowX = 0
    
    if j2>9 then 
        j2 = 10-(dest - 9)
    end

    ballPos = #LK[dest]+1
    if ballPos > 29 then
    	
    	rowY = 0
   		rowX = 0
    	ballPos = ballPos - 29
    end
    if ballPos > 24 then
    	
    	rowY = 60
    	rowX = 15
    	ballPos = ballPos - 24

    elseif ballPos > 19 then
    	
    	rowY = -20
    	rowX = 15
    	ballPos = ballPos - 19

    elseif ballPos > 12 then
    	
    	rowY = 20
    	rowX = -15
    	ballPos = ballPos - 12

    elseif ballPos > 6 then

    	rowY = 40
    	rowX = 0
    	ballPos = ballPos - 6
    
    end

    ballX = (lunkaHeight/2)+ballSize*(ballPos-1)
    ballY = (lunkaWidth+10)*j2+80 

    	if dest > 9 then
    		ballX = display.contentWidth - ballX
            rowX = -rowX
    	end
    -- set params for movement in lunka's using math above
    local params = {
        time = stoneMoveSpeed,
        x = ballX+rowX,
        y = ballY+rowY
    }
    
    table.remove( LK[origin], pos )
    transition.moveTo( stones[stoneId], params)
    table.insert( LK[dest], 1, stoneId )
end

local function initBoard()
	local tek = 1
    local c = 1
    local pos = 1

    for i = 1, 18 do 
    	LK[i] = {} -- 
    	pos = 1
        for j = tek, tek+8  do
            moveStone(stones[c].id,i,i,pos)
            c=c+1
            pos = pos + 1
        end
        tek = tek + 9 
        setKamni(i,9)
    end

    LK[19]={}-- set empty table for kazan 1
    LK[20]={}-- set empty table for kazan 2
    
    setScore(1,0)
    setScore(2,0)   
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

local function moveToKazan(lunkaId, k)
    -- move all stones from lunkaId to kazan of player k
    local currentStones = counter[lunkaId].text -- get # of stones in lunka
    local tekStone	-- temp vars for movement
    local stonePosition -- temp vars for movement
    local currentKazan -- current kazan id for counters
    -- x and y vars for movement of iamge
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
    setKamni(lunkaId,0) -- set counter text to 0
    shifted = false
    -- loop through all the stones in lunka
    for i = 1, currentStones do
    	-- set movement params using x and y vars defined above
    	rowY = (stonesInKazan+i-1)
    	if rowY>58 then
    		rowY = rowY - 58
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
            time = stoneMoveSpeed,
            x = kazanX+rowX,
            y = kazanY+rowY,
            delay = delayToMoveToKazan
        }

        -- set stonePosition to the last id
        stonePosition = currentStones-i+1 -- last stone in group
        
        tekStone = stones[ LK[lunkaId] [stonePosition] ].id -- getting last stone ID in LK[lunkaId]
        
        table.remove( LK[lunkaId], stonePosition)
 
        transition.moveTo( stones[tekStone], params)
        table.insert( LK[currentKazan], 1, tekStone )     
    end
end

local function makeTurn(lunkaId)
	--local sceneGroup = display.view 
	-- takes the lunka id and does the turn:
    local stealStones = false -- if at the end of the turn the stones should be moved to kazan
    local startingPlayer -- temp variable to check if to steal stones
    local lastLunka = lunkaId -- temp variable to check last lunka where the last stone landed

	local currentStones = counter[lunkaId].text -- get number of current stones in starting lunka
	local nextLunkaId -- temp var for next lunka id

    if lunkaId<10 then startingPlayer = 1 -- assign starting player 1 or
    elseif lunkaId>9 then startingPlayer = 2 end -- for player 2
    local tuzdyk = nil
	if startingPlayer==1 then 
		tuzdyk = tuzdyk1 
	else 
		tuzdyk = tuzdyk2 
	end
	
    if (currentStones=="0") then
        -- if the lunka is empty - ignore the click, no changes made, exit function, player turn kept same
        return

    elseif currentStones=="1" then
        -- only 1 stone in lunka, special case for move
        setKamni(lunkaId,0) -- change text counter value
        nextLunkaId = lunkaId+1 -- set next lunka id
        -- check if need to loop from lunka 18 to lunka 1
        if nextLunkaId>18 then 
            nextLunkaId=1
        end
        addKamni(nextLunkaId,1) -- change text counter value in the neighbouring lunka 
        -- check if can steal stones
        if nextLunkaId < 10 and startingPlayer==2 then
        	stealStones = true
        elseif nextLunkaId > 9 and startingPlayer==1 then
        	stealStones = true
        end
        -- move the stone from lunka group LK and the image to new lunka
        moveStone(LK[lunkaId][1],lunkaId,nextLunkaId,1)
        local num = counter[nextLunkaId].text
        --
        if nextLunkaId==tuzdyk1 then
        	moveToKazan(nextLunkaId,1)
        	addScore(1,1)
        elseif nextLunkaId==tuzdyk2 then
        	moveToKazan(nextLunkaId,2)
        	addScore(2,1)
        elseif stealStones and num % 2 == 0 then
            moveToKazan(nextLunkaId,startingPlayer) -- move the stone and stone image to startingPlayer's kazan
        end
    else
    	-- more than 1 stone in lunka
    	setKamni(lunkaId,1) -- set counter at lunka id = 1 according to rules
    	-- assign starting next lunka id value
    	nextLunkaId = lunkaId+1
    	if nextLunkaId>18 then 
            nextLunkaId=1 
        end
      
    	-- move all the remaining stones in the lunka counter-clockwise
    	for i=1,currentStones-1 do
   
    		-- move 1 stone to next lunka
    	
    		addKamni(nextLunkaId,1)
    		-- check if moving within same lunka
    		if lunkaId~=nextLunkaId then
    			-- move stone

    			moveStone(LK[lunkaId][1],lunkaId,nextLunkaId,1) -- move stone in LG lunkaId at pos 1
    		end
    		-- if passing by tuzdyk
    		if nextLunkaId==tuzdyk1 then
    			moveToKazan(nextLunkaId,1)
    			addScore(1,1)
    			--print("passing by tuzdyk, adding to player 1")
    		elseif nextLunkaId==tuzdyk2 then
    			moveToKazan(nextLunkaId,2)
    			addScore(2,1)
    			--print("passing by tuzdyk, adding to player 2")
    		end
    		-- assign last lunka
            lastLunka = nextLunkaId
            -- increment next lunka
    		nextLunkaId=nextLunkaId+1
    		if nextLunkaId>18 then 
           		nextLunkaId=1 
        	end
    	end
    	-- check if can steal stones, by default is false
        if lastLunka>9 and startingPlayer==1 then stealStones = true
        elseif lastLunka<10 and startingPlayer==2 then stealStones = true
        end
 
        -- steal stones if possible
        if stealStones==true then
        	local num = counter[lastLunka].text
       
        	if num % 2 == 0 then
        		-- steal stones!
            	moveToKazan(lastLunka,startingPlayer)
            	addScore(startingPlayer,num)
            end
            if num == "3" then
            	--print("TUZDYK!")
            	if tuzdyk==nil then
            		tuzdyk=lastLunka
            		local check = 19 - lastLunka
            		-- 1 18
            		-- 2 17
            		-- 3 16
            		-- 4 15
            		-- 5 14
            		-- 8 11
            		-- 9 10
            		if startingPlayer==1 and lastLunka==18 then 
            			--cant make tuzdyk
            		elseif startingPlayer==2 and lastLunka==9 then  
            			--cant make tuzdyk
            		elseif tuzdyk1==check or check==tuzdyk2 then
            			-- cant make tuzdyk
            	  else
            		if startingPlayer==1 then 
            			tuzdyk1=tuzdyk
            		else 
            			tuzdyk2=tuzdyk 
            		end
            		
            		lunka[lastLunka] = nil
            		--print("got here")
            		lunka[lastLunka]=display.newImage( "images/"..skin.."_style/tuzdyk.png" )
            		--print(tostring(lunka[lastLunka]))
            		--if lunka[lastLunka]~= nil then sceneGroup:insert(lunka[lastLunka]) end
            		local yL = (lunkaWidth+10)*lastLunka+100
            		local xL = lunkaHeight
            		if startingPlayer==1 then 
            			yL = (lunkaWidth+10)*(18-lastLunka+1) +100
            			xL = display.contentWidth - lunkaHeight
            		end

            		lunka[lastLunka].y = yL
            		lunka[lastLunka].x = xL

            		moveToKazan(lastLunka,startingPlayer)
            		addScore(startingPlayer,3)
            	  end
            	end
            	-- TUZDYK
            end
        end
    end
    -- pass turn to other player
	p1turn = not p1turn
end

local function soundFinished(event)
	
	soundPlaying = true
	if (event.completed) then
		soundPlaying = false
	end
end

--------- automated moves -------------
local function simulateMove(p, i)
    local totalWin = 0
    local L = 0
    local tuz = 0
    local curStones
    local canSteal = false
    local targetL

    if p==2 then 
        curStones = 0 + counter[i+9].text
    else 
        curStones = 0 + counter[i].text
    end

    if curStones == 0 then
        return totalWin, tuz
    elseif curStones == 1 then
        targetL = i+1
        if targetL>9 and p==1 then 
            canSteal=true
        elseif targetL>18 and p==2 then 
            canSteal=true
            targetL=targetL-18
        end

    else
        targetL = i+curStones -1
    end

    --default return 0,0
    return totalWin, tuz
end
---------------------------------------


local function lunkaClick(event)
	local lunkaId = event.target.id
	local i = 1
    
    --local targetLunka
	if lunkaId > 9 then 
        i = 2 
    end
    --print (totalStones[i] .. " total stones")
    if (gameOver==true) and (gameOverWindow~=nil) then 
        return 
        -- check if player can make moves
    elseif (lunkaId < 10) and (p1turn==false) then 
            return 
    elseif (lunkaId > 9) and (p1turn==true) then 
            return 
    end
	if (totalStones[i]==0) and (gameOverWindow==nil) then
        gameOver = true
        gameOverWindow = nil
        
           gameOverWindow = display.newRect( 
                display.contentCenterX, 
                display.contentCenterY, 
                display.contentWidth-100, 
                display.contentWidth-100
                )
            gameOverWindow:setFillColor( 0,0,0 )
            gameOverWindow.alpha = 0.5
            gameOverWindow:addEventListener( "touch", handleBackBtn )
            --sceneGroup(gameOverWindow)
            gameOverText = display.newText( "Ойын аяқталды!\nАстыз қалу!\n"
                                          .. (3-i) .."-ойыншы жеңді!", 
                                          display.contentCenterX, display.contentCenterY, 
                                          native.systemFontBold, 40 )
            gameOverText:setTextColor( 1, 1, 1 )
        
        return true
    end
    if (counter[lunkaId].text=="0") then
            return true
    end
	if  (event.phase == "moved") then
        --print("I am here"..tostring(targetLunka))
        
        if (targetLunka~=nil) then 
            if targetLunka > 0 then
                lunka[targetLunka]:setFillColor( 1,1,1 )
                lunka[targetLunka].alpha = targetAlpha
            end
        end
        targetLunka = 0
        local numStones = 0
        numStones = counter[lunkaId].text
        if numStones == 1 then 
            targetLunka = lunkaId + numStones
        else
            targetLunka = lunkaId + numStones -1
        end
        if targetLunka > 18 then
        repeat
            targetLunka = targetLunka - 18
        until targetLunka < 19
        end
        if targetLunka>0 then
            targetAlpha = lunka[targetLunka].alpha
            lunka[targetLunka]:setFillColor( 0.72, 0.9, 0.16, 0.78  )
            lunka[targetLunka].alpha = 1
        end
    elseif (event.phase=="began") then
        --print("I am here"..tostring(targetLunka))
        
        if (targetLunka~=nil) then 
            if targetLunka > 0 then
                lunka[targetLunka]:setFillColor( 1,1,1 )
                lunka[targetLunka].alpha = targetAlpha
            end
        end

        targetLunka = 0
        local numStones = 0
        numStones = counter[lunkaId].text

        if numStones == 1 then 
            targetLunka = lunkaId + numStones
        else
            targetLunka = lunkaId + numStones -1
        end

        if targetLunka > 18 then
        repeat
            targetLunka = targetLunka - 18
        until targetLunka < 19
        end

        if targetLunka>0 then 
            targetAlpha = lunka[targetLunka].alpha
            lunka[targetLunka]:setFillColor( 0.72, 0.9, 0.16, 0.78  )
            lunka[targetLunka].alpha = 1
        end
    elseif(event.phase == "ended") then
        --targetLunka = 0
        if not (targetLunka==nil) then 
            lunka[targetLunka]:setFillColor( 1,1,1 )
            lunka[targetLunka].alpha = targetAlpha
        end
		-- check if the game is still on
    	
		-- make turn
		if soundPlaying == false then
				audio.play(stoneSnd,{ onComplete=soundFinished })
		end
        --print(lunkaId)
   		makeTurn(lunkaId)  -------getting into makeTurn using the lunkaId
			-- light the board accordingly
    	if p1turn then 
		    otsvetit(1) 
    		podsvetit(2)
    	elseif not p1turn then
		    otsvetit(2) 
    		podsvetit(1)
    	
    	end
    end
end

function scene:create( event )
    local sceneGroup = self.view   
end

function scene:show( event )
    
    local sceneGroup = self.view
    local phase = event.phase
    

    if phase == "will" then
    	totalStones[1]=0
    	totalStones[2]=0
    	local backBtn = widget.newButton{
        	top = 5,
        	left = 5,
        	defaultFile = "images/"..skin.."_style/back_button.png",
        	overFile = "images/"..skin.."_style/back_button_over.png",
        	onEvent = handleBackBtn
    	}      
    	backBtn.x = display.contentCenterX
    	backBtn.y = 80
    	
 
        -- init board
        background = display.newImage( "images/"..skin.."_style/board.png" )
        background.x = display.contentCenterX
        background.y = display.contentCenterY
        if skin=="black" then
           background.alpha=0.3
        end
        sceneGroup:insert(background)

        -- draw lunkas
        for i = 1, 9 do
            -- top row Player 1 (indices from 1 to 9)
            lunka[i] = display.newImage(lunkaImg)
            sceneGroup:insert(lunka[i])
            lunka[i].y = (lunkaWidth+10)*i+100
            lunka[i].x = lunkaHeight
            lunka[i].id = i
            counter[i] = display.newText(
                                        "00", 10,
                                        (lunkaWidth+10)*i+100, 
                                        native.systemFontBold, 30 )
            counter[i]:rotate(90)
            
            sceneGroup:insert(counter[i])
            
            counter[i]:setTextColor(0.3, 0.36, 0.91)
            -- bottom row Player 2 (indices from 10 to 18)
            lunka[i+9]= display.newImage(lunkaImg)
            
            sceneGroup:insert(lunka[i+9])
            
            lunka[i+9].y = (lunkaWidth+10)*(10-i)+100
            lunka[i+9].x = display.contentWidth - lunkaHeight
            lunka[i+9].id = i+9
            counter[i+9] = display.newText(
                                        "00", display.contentWidth - 10 ,
                                        (lunkaWidth+10)*(10-i)+100, 
                                        native.systemFontBold, 30 )
            counter[i+9]:rotate(-90)
            
            sceneGroup:insert(counter[i+9])
            
            counter[i+9]:setTextColor(0.3, 0.36, 0.91)

            lunka[i]:addEventListener( "touch", lunkaClick )
            lunka[i+9]:addEventListener( "touch", lunkaClick )
        end

        -- draw kazans
        kazan[1]= display.newImage("images/"..skin.."_style/kazan.png")
        sceneGroup:insert(kazan[1])
        kazan[1].y = display.contentCenterY + 50
        kazan[1].x = display.contentCenterX - 30
        kazan[2]= display.newImage("images/"..skin.."_style/kazan.png")
        sceneGroup:insert(kazan[2])
        kazan[2].y = display.contentCenterY + 50
        kazan[2].x = display.contentCenterX + 30

        counter.player1 = display.newText(
                                        "0", 
                                        80, 
                                        124, 
                                        native.systemFontBold, 30
            )
        sceneGroup:insert(counter.player1)
        counter.player1:setTextColor(0.3, 0.36, 0.91)
        counter.player2 = display.newText(
                                        "0", 
                                        display.contentWidth - 80, 
                                        124, 
                                        native.systemFontBold, 30
            )
        sceneGroup:insert(counter.player2)
        counter.player2:setTextColor(0.3, 0.36, 0.91)

        -- add stones
        
        for i = 1, 18 do
            for j = (i-1)*9+1, i*9 do
                stones[j] = display.newImage("images/"..skin.."_style/ball.png")
                if (skin~="wood") then
                    stones[j].xScale = 0.75
                    stones[j].yScale = 0.75
                end
                sceneGroup:insert(stones[j])
                stones[j].x = 0
                stones[j].y = 0
                stones[j].id = j
            end
        end
        
        -- give turns
        local turnX = math.random( 2 )
    	if turnX==1 then 
    		p1turn=true 
    	elseif turnX==2 then
    		p1turn=false 
    	end

        if p1turn then 
    		otsvetit(1) 
    		podsvetit(2)
   		elseif not p1turn then
   		 	otsvetit(2) 
    		podsvetit(1)
   		end
   		sceneGroup:insert(backBtn)
        -- start game
        
    elseif phase == "did" then
        initBoard()
        Runtime:addEventListener( "key", onKeyEvent )
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
    	if (tuzdyk1~= nil) and (lunka[tuzdyk1]~= nil) then
    		lunka[tuzdyk1]:removeSelf( )
            lunka[tuzdyk1]=nil
    	end
    	if tuzdyk2~= nil and (lunka[tuzdyk2]~= nil) then
    		lunka[tuzdyk2]:removeSelf( )
            lunka[tuzdyk2]=nil
    	end
    	tuzdyk1 = nil
    	tuzdyk2 = nil
    	gameOver = false
    	if gameOverWindow ~= nil then  
    		gameOverWindow:removeSelf( ) 
            gameOverWindow= nil
    	end
        
    	if gameOverText ~= nil then
    		gameOverText:removeSelf( )
            gameOverText=nil
            
    	end
    elseif phase == "did" then
        collectgarbage()
    end 
end

function scene:destroy( event )
    local sceneGroup = self.view
    if sceneGroup ~= nil then 
        sceneGroup:removeSelf( ) 
        sceneGroup = nil
    end
    --composer.removeScene( "board" )
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
