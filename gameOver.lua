local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local gameSettings = composer.getVariable("gameSettings")
local turnback = composer.getVariable( "turnback" )

local strings = composer.getVariable("strings")
local lang = gameSettings.language
local vars
local parent

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
        if vars.state=="pause" then
        	--composer.gotoScene("game")
        else
        	composer.gotoScene("menu")
        end
    end
end


local function hideScene(event)
	composer.hideOverlay( "fade", 400 )
end

local function gotoOptions(event)
	composer.hideOverlay("fade",200)
	composer.gotoScene("options")
end

local function goBackListener(event)
	
	
	parent:goBack()
	-- print("go back listerner started")
	-- for k, v in pairs( localdata ) do
 --            print(k, v)
 --    end
 --    print("printing table ended")
	-- --parent: cleanBoard(sceneGroup)
	--parent: drawBoard(skin, sceneGroup)
	-- parent: initBoard(localdata)
	composer.hideOverlay( "fade" ,200 )
	parent:cleanBoardGameAndLoadNewBoard()
	print("cleaning board and loading is done")
	
end


function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase
	vars = event.params
	parent = event.parent
	--print("parent is "..tostring(parent))
	if (phase=="will") then
		local background = display.newImage("images/gameOverBackground.png")
		background.x = display.contentCenterX
		background.y = display.contentCenterY
		sceneGroup:insert(background)
		--background:addEventListener("tap", hideScene)
		if vars.state=="pause" then
			local pauseText = display.newEmbossedText(">".. strings[lang.."Pause"][1].."<",
      			display.contentCenterX,
      			display.contentCenterY-50,
      			native.systemFont, 80 )
			sceneGroup:insert(pauseText)
			pauseText:addEventListener("tap",hideScene)
			local optionsText = display.newEmbossedText( strings[lang.."Pause"][2],
      			display.contentCenterX,
      			display.contentCenterY+50,
      			native.systemFont, 40 )
			sceneGroup:insert(optionsText)
			optionsText:addEventListener("tap",gotoOptions)
			local goBackText = display.newEmbossedText( strings[lang.."Pause"][3],
      			display.contentCenterX,
      			display.contentCenterY+100,
      			native.systemFont, 40 )
			sceneGroup:insert(goBackText)
			goBackText:addEventListener( "tap", goBackListener )
		elseif vars.state=="gameOver" then
			local gameOverText = display.newEmbossedText( strings[lang.."GameOver"][1],
      			display.contentCenterX,
      			display.contentCenterY-30,
      			native.systemFont, 40 )
			sceneGroup:insert(gameOverText)
			background:addEventListener("tap", hideScene)
			local winnerText = display.newEmbossedText(vars.winner.." "..strings[lang.."GameOver"][2],
      			display.contentCenterX,
      			display.contentCenterY+30,
      			native.systemFont, 40 )
			sceneGroup:insert(winnerText)
		else
			local gameOverText = display.newEmbossedText( strings[lang.."GameOver"][1],
      			display.contentCenterX,
      			display.contentCenterY-30,
      			native.systemFont, 40 )
			sceneGroup:insert(gameOverText)
			background:addEventListener("tap", hideScene)
			local winnerText = display.newEmbossedText(vars.winner.." "..strings[lang.."GameOver"][3],
      			display.contentCenterX,
      			display.contentCenterY+30,
      			native.systemFont, 40 )
			sceneGroup:insert(winnerText)
		end
	end
end


-- By some method (a "resume" button, for example), hide the overlay


scene:addEventListener( "hide", scene )
scene:addEventListener("show" ,scene)

return scene