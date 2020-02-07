#!/bin/bash
set -e
getpid() {
   # pid=`ps aux | grep ${main_class} | grep -v grep | awk '{print $2}'`
	module=$1
	if [ -e "./${module}_pid" ]; then
		pid=`cat ./${module}_pid`
	fi
	if [[ -n ${pid} ]]; then
		break 1
	else
		break 0
	fi
}

mklogsdir() {
    if [[ ! -d "logs" ]]; then
        mkdir logs
    fi
}

start() {
    getpid ${module}
    if [[ $? -eq 0 ]]; then
        mklogsdir
        if [[ ! -e "fate-${module}.jar" ]]; then
          ln -s fate-${module}-${module_version}.jar fate-${module}.jar
        fi
	if [ ${module} = "serving-server" ]
	then
        	java  -cp "conf/:lib/*:fate-${module}.jar" ${main_class} -c conf/${module}.properties >> logs/console.log 2>>logs/error.log &
	elif [ ${module} = "serving-proxy" ]
	then
		        java -Dspring.config.location=${configpath}/application.properties  -cp "conf/:lib/*:fate-${module}.jar" ${main_class} -c conf/application.properties >> logs/console.log 2>>logs/error.log &

	else
		echo ""
	fi
	sleep 5
	id=`ps -p $!| awk '{print $1}'|sed -n '2p'`
        if [[ ${#id} -ne 0 ]]; then
            echo $!>./${module}_pid
            getpid $module
            echo "service start sucessfully. pid: ${pid}"
        else
            echo "service start failed"
        fi
    else
        echo "service already started. pid: ${pid}"
    fi
}

status() {
    getpid $1
    if [[ -n ${pid} ]]; then
        echo "status:
        `ps -f -p ${pid} `"
        exit 1
    else
        echo "service not running"
        exit 0
    fi
}


stop() {
    getpid $1
    if [[ -n ${pid} ]]; then
        echo "killing:
        `ps -p ${pid}`"
	echo "--------------" ${pid}
        kill ${pid}
        if [[ $? -eq 0 ]]; then
	    rm -rf ./${module}_pid
            echo "killed"
        else
            echo "kill error"
        fi
    else
        echo "service not running"
    fi
}