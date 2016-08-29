#!/bin/bash
cd $(dirname $0)

ProInfo=proList.txt
sendSMS=sendSMS.py
IPAddress=$(/sbin/ip -4 addr | /bin/awk '/ global /{print $2;exit}' | /bin/sed  's/\/.*//')

logFile=sms_$(date "+%F").log
function printlog(){
	echo $(date "+%F %T") $1 $2 $3 $4  >> $logFile
}


ProList=$(awk '$0 ~  /^[a-zA-Z0-9]/{print $1}' $ProInfo)
for pro in $ProList
do
	receivers=$(grep "^$pro" $ProInfo |awk '{print $2}' )
	
	curTime=$(date "+%F %T")
	comment="[$curTime]aws-ERR:${Pro}[$IPAddress] is not exist"
	#comment="[$curTime]aws-ERR:${Pro}[$IPAddress] is running"
	
	PID=$(ps -ef | grep java | grep "$Pro"|grep -v grep |awk '{print $2}')
	if [ -z $PID ]
	then
			printlog "ERR: $pro is not exist"
			/usr/bin/python $sendSMS "$receivers" "${comment}"  >> $logFile
	else
			printlog "INFO: $pro is running"
			/usr/bin/python $sendSMS "$receivers" "${comment}" 
	fi
done

rm -f sms_$(date -d '7 days ago' "+%F").log