local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local menuTop =  composer.getVariable( "menuTop" )+0
local menuLeft = composer.getVariable( "menuLeft" )+0
local gameSettings = composer.getVariable( "gameSettings" )
local playerID,alias,msg
composer.gameNetwork = require("gameNetwork")
--------------------


--------------------------------------------


function scene:create( event )
  local sceneGroup = self.view
  
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        
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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene