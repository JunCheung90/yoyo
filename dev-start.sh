YOYOPATH="/home/chenqan/code/web/yoyo"
cd ${YOYOPATH}
echo "start mongodb"
terminal -x mongod -f ./mongodb.conf &

echo "start node-inspector"
terminal -x node-inspector &

echo "compile yoyo server"
cd ${YOYOPATH}/src
terminal -x lsc -wcbdo ../bin . &

echo "compile testing code"
cd ${YOYOPATH}/test
terminal -x lsc -wcbdo ../test-bin . &

#add sleep time
sleep 1

echo "run yoyo server"
cd ${YOYOPATH}
terminal -x supervisor bin/app.js &

#echo "integrated testing"
#cd ${YOYOPATH}
#terminal -x nodemon -w ./bin -w ./test-bin/integrated
#./node_modules/mocha/bin/mocha ./test-bin/integrated -R spec

echo "unit testing"
cd ${YOYOPATH}
terminal -x nodemon -w ./bin -w ./test-bin/unit ./node_modules/mocha/bin/mocha ./test-bin/unit/test-call-log-mining.js -R spec &

sleep 1
echo "start data-mining process"
cd ${YOYOPATH}
terminal -x node ./bin/data-mining/daemon-miner.js
