#!/bin/bash
MYSQL_PASSWORD=UD7UjboCneHBvOJA
 
 
/usr/local/mysql/bin/mysql -uroot -p$MYSQL_PASSWORD -e "show status;" >/dev/null 2>&1
if [ $? == 0 ]
then
    echo " $host mysql login successfully "
    exit 0
else
    echo " $host mysql login faild"
    service keepalived status
    exit 2
fi
