local composer = require( "composer" )
local scene = composer.newScene()

local widget = require("widget")
local gameSettings = composer.getVariable( "gameSettings" )

-- network data
composer.gameNetwork = require( "gameNetwork" )
local playerID
local alias
local thisGroup
local texts = {}
local friends = {}
local menuBackground
local myText
local scrollView
--------------------
local function handleBackBtn(event)
    if ("ended"==event.phase) then
        composer.gotoScene("menu")
    end
end

local function requestLoadFriendsCallback(event)
    friends = event.data
    local newText = display.newText(thisGroup,"Friends list",100,20,native.systemFontBold,40)
    local paragraphs = {}
    local paragraph

    scrollView = widget.newScrollView
    {
        top = 140,
        left = 10,
        width = display.contentWidth-0,
        height = display.contentHeight-300,
        scrollWidth = display.contentWidth-50,
        scrollHeight =1000,
        hideBackground = true
    }
    local options = {
        text = "",
        left = 10,
        width = display.contentWidth-50,
        font = native.systemFontBold,
        fontSize = 40,
        align = "left"
    }
    local yOffset = 10

    if #friends>0 then
        for i=1,#friends do
            paragraph = friends[i].alias
            options.text = paragraph.."\n"
            paragraphs[#paragraphs+1] = display.newText( options )
            paragraphs[#paragraphs].anchorX = 0
            paragraphs[#paragraphs].anchorY = 0
            paragraphs[#paragraphs].x = 10
            paragraphs[#paragraphs].y = yOffset
            paragraphs[#paragraphs]:setFillColor( 1,1,1 )
            scrollView:insert( paragraphs[#paragraphs] )
            yOffset = yOffset + paragraphs[#paragraphs].height
        end
        
    end
    thisGroup:insert(scrollView)
end

local function drawWelcomeScreen()
    menuBackground = display.newImage( "images/rules_bg.png")
    menuBackground.x = display.contentCenterX
    menuBackground.y = display.contentCenterY
    thisGroup:insert(menuBackground)

    local backBtn = widget.newButton{
            top = 35,
            left = 240,
            defaultFile = "images/back.png",
            overFile = "images/back.png",
            onEvent = handleBackBtn
        }
    thisGroup:insert(backBtn)

    composer.gameNetwork.request( "loadFriends", { listener=requestLoadFriendsCallback } )
    
<<<<<<< HEAD
end

local function requestLoadLocalPlayerCallback (event)
    playerID = event.data.playerID
    alias = event.data.alias
    local msg = "Welcome, "..alias..", you are also "..playerID
    composer.playerID = playerID
    composer.alias = alias
    drawWelcomeScreen()
end

local function requestCallback ( event )
    if composer.gameNetwork.request("isConnected") then
        composer.gameNetwork.request( "loadLocalPlayer", { listener = requestLoadLocalPlayerCallback } )
    else
        native.showAlert("You are not connected","!",{"OK"})
    end
=======
   
>>>>>>> origin/master
end


local function initCallback( event )
    if not event.isError then
<<<<<<< HEAD
        composer.gameNetwork.request( "login",
          {
=======
       
        gameNetwork.request( "login",
        {
>>>>>>> origin/master
            userInitiated = true,
            listener = requestCallback
        }
        )
        native.showAlert( "Success!", "", { "OK" } )
    else
        native.showAlert( "Failed!", event.errorMessage, { "OK" } )
    end
end

local function onSystemEvent( event )
    -- body
end

--------------------------------------------


function scene:create( event )
  local sceneGroup = self.view
  
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    thisGroup = sceneGroup
    if phase == "will" then
        composer.gameNetwork.init("google",initCallback)
    elseif phase == "did" then
        
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        for i=1,sceneGroup.numChildren do
            if sceneGroup[i]~=nil then 
                sceneGroup[i]:removeSelf()
            end
        end
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