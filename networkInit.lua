local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local menuTop =  composer.getVariable( "menuTop" )+0
local menuLeft = composer.getVariable( "menuLeft" )+0
local gameSettings = composer.getVariable( "gameSettings" )
local playerID,alias,msg

-- network data
local gameNetwork = require( "gameNetwork" )
--------------------
local function requestCallback ( event )
  playerID = event.data.playerID
  alias = event.data.alias
  msg = playerID.." is ID and alias is" ..alias

end

--------------------------------------------


function scene:create( event )
  local sceneGroup = self.view
  
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        gameNetwork = composer.getVariable( "gameNetwork" )
        gameNetwork.request( "loadLocalPlayer", { listener=requestCallback } )
        local text1 = display.newText( sceneGroup, playerID, display.contentCenterX,
         display.contentCenterY, native.systemFontBold, 40 )
        text1:setTextColor( 1, 1, 1 )
        text1.x = display.contentCenterX
        text1.y = display.contentCenterY
        local text2 = display.newText( sceneGroup, alias, display.contentCenterX, 
          display.contentCenterY+50, native.systemFontBold, 40 )
        text2:setTextColor( 1, 1, 1 )
        text2.x = display.contentCenterX
        text2.y = display.contentCenterY+50
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