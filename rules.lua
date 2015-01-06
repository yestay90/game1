local composer = require( "composer" )
local scene = composer.newScene()
local menuTop =  composer.getVariable( "menuTop" )
local menuLeft = composer.getVariable( "menuLeft" )
local gameSettings = composer.getVariable( "gameSettings" )
local strings = composer.getVariable( "strings" )
local widget = require("widget")
local myText
local scrollView
local menuBackground
local arrow

local function handleBackBtn(event)
    if ("ended"==event.phase) then
        composer.gotoScene("menu")
    end
end

local function scrollEventListener ( event )

    return true
end

local function loadRules(lang)
    local rulesPath = system.pathForFile( "rules_"..lang..".txt", system.ResourceDirectory )
    local fileHandle, errorString = io.open(rulesPath,"r")
    if fileHandle then
        local contents = fileHandle:read( "*a" )
        io.close( fileHandle )
        return contents
    else
        io.close( fileHandle )
        print(lang.." does not exist")
        return "no text found"
    end
end

function scene:create( event )
    local sceneGroup = self.view
    language = gameSettings.language
    myText = loadRules(language)

    menuBackground = display.newImage( "images/rules_bg.png")
    menuBackground.x = display.contentCenterX
    menuBackground.y = display.contentCenterY
    sceneGroup:insert(menuBackground)

    local backBtn = widget.newButton{
            top = 35,
            left = 240,
            defaultFile = "images/back.png",
            overFile = "images/back.png",
            onEvent = handleBackBtn
        }
    sceneGroup:insert(backBtn)

end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then

        language = gameSettings.language
        myText = loadRules(language)
        local paragraphs = {}
    local paragraph
    local tmpString = myText

    scrollView = widget.newScrollView
    {
        top = 140,
        left = 10,
        width = display.contentWidth-0,
        height = display.contentHeight-300,
        scrollWidth = display.contentWidth-200,
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

    repeat
        paragraph, tmpString = string.match( tmpString, "([^\n]*)\n(.*)" )
        if (paragraph~=nil) then
            options.text = paragraph
            paragraphs[#paragraphs+1] = display.newText( options )
            paragraphs[#paragraphs].anchorX = 0
            paragraphs[#paragraphs].anchorY = 0
            paragraphs[#paragraphs].x = 10
            paragraphs[#paragraphs].y = yOffset
            paragraphs[#paragraphs]:setFillColor( 1,1,1 )
            scrollView:insert( paragraphs[#paragraphs] )
            yOffset = yOffset + paragraphs[#paragraphs].height
        end
    until tmpString == nil or string.len( tmpString ) == 0

    sceneGroup:insert(scrollView)
    elseif phase == "did" then
        
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        sceneGroup:remove(scrollView)
        scrollView:removeSelf( )
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