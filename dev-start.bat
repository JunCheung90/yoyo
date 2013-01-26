start "mongoDB" /D %MONGO_HOME%\bin mongod.exe --dbpath d:\mongodb-data
start "node-inspector" node-inspector
start "SOURCE CODE" /D .\src lsc -wcbo . livescript
start "YoYo SERVER" supervisor src\server.js
start "TESTING CODE" /D .\test lsc -wcbo . livescript
start "UNIT TESTING" /D .\test\unit mocha test-mongo-direct -R Spec
' start "INTIGRATED TESTING" /D .\test\integrated mocha -R Spec