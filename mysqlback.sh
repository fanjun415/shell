#!/bin/bash
rm -rf /data/mysql/all_data_*
/usr/local/mysql/bin/mysqldump -A -B --single-transaction --flush-logs --master-data=2 --all-databases >/data/mysql/all_data_`date +%Y%m%d%H%M%S`.sql
chown mysql.mysql /data/mysql/all_data_*
