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
      io.close( fileHandle )
      
  	else
      
      fileHandle = io.open( dataPath,"w" )
      fileHandle:write( [[{"difficulty":"easy","language":"ru","highScore":"0","playerName":"Talgat","skin":"wood"}]] )
  	  io.close( fileHandle )
      local fileHandle, errorString = io.open(dataPath,"r")
      local contents = fileHandle:read( "*a" )
      local decoded, pos, msg = json.decode( contents )
      -- gameSettings = loadsave.loadTable("data.json")
      gameSettings = decoded
      composer.setVariable( "gameSettings", gameSettings )
      language = gameSettings.language
      io.close( fileHandle )
    end
  	
  	-- load strings
    
	local fileHandle, errorString = io.open(stringsPath,"r")
  
	if fileHandle then
    	local contents = fileHandle:read( "*a" )
    	strings = loadsave.loadTable("strings.json")
    	composer.setVariable( "strings", strings )
      io.close( fileHandle )
      
	else
    
   local fileHandle = io.open(stringsPath, "w" )
   fileHandle:write([[{
      "mainMenu":["networkGame","gameMenu","options","rules"],
      "enMenu":["Play online","Local game","Options","Game rules"],
      "kzMenu":["Интернет арқылы ойнау","Локалды ойнау","Параметрлер","Ойын шарттары"],
      "ruMenu":["Играть по сети","Играть локально","Настройки","Правила игры"],
      "gameMenu":["newGame","loadGame","localMultiplayer","menu"],
      "ruGameMenu":["Новая игра","Загрузить игру","Играть вдвоем", "<- Вернуться"],
      "enGameMenu":["New game","Load game","Two player game", "<- Go back"],
      "kzGameMenu":["Жаңа ойын","Ойынды жүктеу","Екі адамды ойын", "<- Артқа"],
      "optionsMenu":["language","skin", "level","menu"],
      "enOptions":["Language","Skin","Level of difficulty","<- Go back"],
      "ruOptions":["Язык","Оформление", "Уровень сложности","<- Вернуться"],
      "kzOptions":["Тіл","Тақтаның түсі", "Қиындық деңгейі","<- Артқа"],
      "difficultyLevelMenu":["easy","medium","hard"],
      "enDifficulty":["Easy","Medium","Hard"],
      "ruDifficulty":["Легкий","Средний","Трудный"],
      "kzDifficulty":["Оңай","Орташа","Қиын"],
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
      "kzPause":["Пауза","Параметрлер", "<- Артқа жылжыту"],
      "ruPause":["Пауза","Настройки", "Ход назад"],
      "enPause":["Pause","Options", "Move back"],
      "ruGameOver":["Игра окончена!", "игрок победил!","Нет хода!","Очков","Новый рекорд!"],
      "kzGameOver":["Ойын аяқталды!", "-ойыншы ұтты!","Атсыз қалу!","Ұпай","Ең үлкен ұпай!"],
      "enGameOver":["Game over!", "Player win","No more moves!","Points","Personal highscore!"]
    }]]
    )
    
    io.close( fileHandle )
    local fileHandle, errorString = io.open(stringsPath,"r")
    local contents = fileHandle:read( "*a" )
    local decoded, pos, msg = json.decode( contents )
      strings = decoded
      composer.setVariable( "strings", strings )
      io.close( fileHandle )
      
	 end
  
  composer.setVariable( "menuTop", 600 )
  composer.setVariable( "menuLeft", 70 )
  composer.setVariable("newGame",false)
end
--initialize user data
loadUserData()
--show logo
composer.gotoScene( "ulttyqlogo" )