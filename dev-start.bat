start "mongoDB" /D %MONGO_HOME%\bin mongod.exe -f mongodb.conf
start "node-inspector" node-inspector
start "SOURCE CODE" /D .\src lsc -wcbdo ..\bin .
start "YoYo SERVER" supervisor bin\server.js
start "TESTING CODE" /D .\test lsc -wcbdo ..\test-bin .
start "UNIT TESTING" nodemon -w .\bin -w .\test-bin\unit .\node_modules\mocha\bin\mocha .\test-bin\unit -R Spec
' start "INTIGRATED TESTING" nodemon -w .\bin .\node_modules\mocha\bin\mocha .\test-bin\integrated\test.js -R Spec
' 将下面命令copy到打开的命令行窗口执行, 运行所有测试。
' "%PROGRAMFILES(x86)%\Git\bin\find" test-bin -name 'test-*.js' | xargs .\node_modules\mocha\bin\mocha -R spec