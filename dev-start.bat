start "mongoDB" /D %MONGO_HOME%\bin mongod.exe --dbpath d:\mongodb-data
start "node-inspector" node-inspector
start "����Դ����" /D .\src lsc -wcbo . livescript
start "YoYo������" supervisor src\server.js
start "������Դ���" /D .\test lsc -wcbo . livescript
start "��Ԫ����" /D .\test\unit mocha test-mongo-direct -R Spec
' start "���ɲ���" /D .\test\integrated mocha -R Spec
