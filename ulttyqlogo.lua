local composer = require( "composer" )
local widget = require("widget")
local backBtn
local clicked = false

local scene = composer.newScene(  )

local function logoClick (event)
        if not clicked then
            clicked = true
            composer.gotoScene("menu")
        end
    
end

function scene:create( event )
	
    local sceneGroup = self.view
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        local logo = display.newImage("images/logo.png")
        logo.x = display.contentCenterX
        logo.y = display.contentCenterY
        logo.xScale = 1.2
        logo.yScale = 1.2
        local params = {
        	time = 2000,
        	onComplete = logoClick
    	}
        transition.to( logo, params )
        logo:addEventListener( "touch", logoClick )
        sceneGroup:insert(logo)

    elseif phase == "did" then

    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        
    elseif phase == "did" then
       
    end 
end

function scene:destroy( event )
    local sceneGroup = self.view
    sceneGroup:removeSelf()
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
