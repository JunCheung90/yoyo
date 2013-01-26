start "mongoDB" /D %MONGO_HOME%\bin mongod.exe --dbpath d:\mongodb-data
start "node-inspector" node-inspector
start "SOURCE CODE" /D .\src lsc -wcbo . livescript
start "YoYo SERVER" supervisor src\server.js
start "TESTING CODE" /D .\test lsc -wcbo . livescript
start "UNIT TESTING" nodemon -d 30 -w .\src -w .\test\unit .\node_modules\mocha\bin\mocha .\test\unit\test.js -R Spec
' start "INTIGRATED TESTING" nodemon -w .\src .\node_modules\mocha\bin\mocha .\test\integrated\test.js -R Spec