display.setStatusBar( display.HiddenStatusBar )
local composer 		= require "composer"
local json 			= require "json"
local stringsPath 	= system.pathForFile( "strings.json",system.DocumentsDirectory )
local dataPath 		= system.pathForFile( "data.json", system.DocumentsDirectory )
local loadsave		= require("loadsave")
local gameSettings
local strings

local function loadUserData()
  
  local fileHandle, errorString = io.open(dataPath,"r")
    -- load settings
    if fileHandle then
	    local contents = fileHandle:read( "*a" )
	    local decoded, pos, msg = json.decode( contents )
	    gameSettings = loadsave.loadTable("data.json")
	    composer.setVariable( "gameSettings", gameSettings )
	    language = gameSettings.language
  	else
      fileHandle = io.open( dataPath,"w" )
      fileHandle:write( [[{"difficulty":"easy","language":"ru","highScore":"0","playerName":"Talgat","skin":"wood"}]] )
  	end
  	io.close( fileHandle )
  	-- load strings
	local fileHandle, errorString = io.open(stringsPath,"r")
  
	if fileHandle then
    	local contents = fileHandle:read( "*a" )
    	strings = loadsave.loadTable("strings.json")
    	composer.setVariable( "strings", strings )
	else
   local fileHandle = io.open( stringsPath, "w" )
    fileHandle:write([[{
      "enMenu":["Play vs robot","Play vs player","Options","Game rules","Load game"],
      "kzMenu":["Роботқа қарсы ойнау","Басқа адаммен ойнау","Параметрлер","Оыйн шарттары","Ойынды жүктеу"],
      "mainMenu":["gameVsRobot","game","options","rules","loadGame"],
      "ruMenu":["Играть против робота","Играть против игрока","Настройки","Правила игры","Загрузить игру"],
      "optionsMenu":["language","skin","menu"],
      "enOptions":["Language","Skin","<- Go back"],
      "ruOptions":["Язык","Оформление","<- Вернуться"],
      "kzOptions":["Тіл","Тақтаның түсі","<- Артқа"],
      "languageMenu":["kz","ru","en"],
      "enLanguages":["Kazakh","Russian","English"],
      "ruLanguages":["Казахский","Русский","Английский"],
      "kzLanguages":["Қазақша","Орысша","Ағылшынша"],
      "kzRules":"kzRules.txt",
  	  "ruRules":"ruRules.txt",
  	  "enRules":"enRules.txt",
      "skinMenu":["wood","black","orange","tree"],
      "kzSkins":["Қоңыр","Қара","Апельсин","Ағаш"],
      "ruSkins":["Коричнывый","Черный","Оранжевый","Древесный"],
      "enSkins":["Wood","Black","Orange","Tree"],
      "kzPause":["Пауза","Параметрлер"],
      "ruPause":["Пауза","Настройки"],
      "enPause":["Pause","Options"],
      "ruGameOver":["Игра окончена!", "игрок победил!","Нет хода!","Очков","Новый рекорд!"],
      "kzGameOver":["Ойын аяқталды!", "-ойыншы ұтты!","Атсыз қалу!","Ұпай","Ең үлкен ұпай!"],
      "enGameOver":["Game over!", "Player win","No more moves!","Points","Personal highscore!"]
    }]])
	end
  io.close( fileHandle )
  composer.setVariable( "menuTop", 600 )
  composer.setVariable( "menuLeft", 70 )
  composer.setVariable("newGame",false)
end
--initialize user data
loadUserData()
--show logo
composer.gotoScene( "ulttyqlogo" )