local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()
local ThissceneGroup

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  --reference to the parent scene object

    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
        composer.gotoScene("menu")
    end
end


local function hideScene(event)
	composer.hideOverlay( "fade", 400 )
end


function scene:show(event)
	local sceneGroup = self.view
	local phase = event.phase

	if (phase=="will")
		then
		print("YO!")
		local background = display.newImage("images/gameOverBackground.png")
		background.x = display.contentCenterX
		background.y = display.contentCenterY
		sceneGroup:insert(background)
		background:addEventListener("tap", hideScene)
	end
end


-- By some method (a "resume" button, for example), hide the overlay


scene:addEventListener( "hide", scene )
scene:addEventListener("show" ,scene)

return scene