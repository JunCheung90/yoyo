start "mongoDB" /D %MONGO_HOME%\bin mongod.exe -f mongodb.conf
start "node-inspector" node-inspector
start "SOURCE CODE" /D .\src lsc -wcbdo ..\bin .
start "YoYo SERVER" supervisor bin\server.js
start "TESTING CODE" /D .\test lsc -wcbdo ..\test-bin .
start "UNIT TESTING" nodemon -w .\bin -w .\test-bin\unit .\node_modules\mocha\bin\mocha .\test-bin\unit\test.js -R Spec
' start "INTIGRATED TESTING" nodemon -w .\bin .\node_modules\mocha\bin\mocha .\test-bin\integrated\test.js -R Spec