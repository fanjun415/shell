#!/bin/bash

###################################

###################################

function delete_indices() {
    comp_date=`date -d "2 day ago" +"%Y-%m-%d"`
    date1="$1 00:00:00"
    date2="$comp_date 00:00:00"

    t1=`date -d "$date1" +%s`
    t2=`date -d "$date2" +%s`

    if [ $t1 -le $t2 ]; then
        format_date=`echo $1| sed 's/-/\./g'`

        curl -XDELETE http://localhost:19200/*$format_date
    fi
}

curl -XGET http://localhost:19200/_cat/indices | awk -F" " '{print $3}' | awk -F"-" '{print $NF}' | egrep "[0-9]*\.[0-9]*\.[0-9]*" | sort | uniq  | sed 's/\./-/g' | while read LINE
do
    delete_indices $LINE
done
