' start "YoYo Mock dev" cd /D .\examples
start "YoYo Mock" supervisor .\examples\node_generateSet.js
' start "node-inspector" node-inspector
start "SOURCE CODE" /D .\lib\livescript lsc -wcbo ..\ .
start "TESTING CODE" /D .\test\livescript lsc -wcbo ..\ .
start "UNIT TESTING" nodemon -w .\test\unit\random-test.js .\node_modules\mocha\bin\mocha .\test\unit\random-test.js -R Spec -t 5s