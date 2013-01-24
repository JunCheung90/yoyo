start "mongoDB" /D %MONGO_HOME%\bin mongod.exe --dbpath d:\mongodb-data
start "node-inspector" node-inspector
start "编译源代码" /D .\src lsc -wcbo . livescript
start "YoYo服务器" supervisor src\server.js
start "编译测试代码" /D .\test lsc -wcbo . livescript
start "单元测试" /D .\test\unit mocha test-mongo-direct -R Spec
' start "集成测试" /D .\test\integrated mocha -R Spec
