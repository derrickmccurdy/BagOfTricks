sudo rsync -avz -e ssh /var/lib/mysql/datastore/tblmaster.*  63.216.48.224:/var/lib/mysql/datastore/

grant replication slave on *.* to 'rep1'@'63.216.48.224' identified by '45t3r15k' ;
? grant replication slave on 'datastore'.'tblmaster' to 'rep1'@'63.216.48.224' identified by '45t3r15k' ;


show master status ;


CHANGE MASTER TO MASTER_HOST='63.216.48.223', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000002', MASTER_LOG_POS=473 ;




slave start ;

slave stop ;

stop slave ;


reset slave ;


-- email hash
 select conv(substr(md6(email),17,32),16,10) from tblmaster limit 10 ;

:wq

slave stop ;
CHANGE MASTER TO MASTER_HOST='216.66.17.204', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000034', MASTER_LOG_POS=919 ;
slave start ;


+------------------+-----------+--------------+------------------+
| File             | Position  | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+-----------+--------------+------------------+
| mysql-bin.000035 | 299707666 |              |                  |
+------------------+-----------+--------------+------------------+
CHANGE MASTER TO MASTER_HOST='216.66.17.204', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;




204
198	197	196
198
grant replication slave on *.* to 'rep1'@'216.66.17.195' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.194' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.193' identified by '45t3r15k' ;
197
grant replication slave on *.* to 'rep1'@'216.66.17.192' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.191' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.190' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.189' identified by '45t3r15k' ;
196
grant replication slave on *.* to 'rep1'@'216.66.17.188' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.187' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.186' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'216.66.17.180' identified by '45t3r15k' ;



198
*195	194	193
CHANGE MASTER TO MASTER_HOST='216.66.17.198', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;


197
192	191	*190	189
CHANGE MASTER TO MASTER_HOST='216.66.17.197', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;


196
188	187	186	180
CHANGE MASTER TO MASTER_HOST='216.66.17.196', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;


CHANGE MASTER TO MASTER_HOST='216.66.17.196', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;



master
grant replication slave on *.* to 'rep1'@'67.217.39.116' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.104' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.100' identified by '45t3r15k' ;
lsim0
grant replication slave on *.* to 'rep1'@'67.217.39.103' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.101' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.99' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.102' identified by '45t3r15k' ;
lsim1
grant replication slave on *.* to 'rep1'@'67.217.39.122' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.123' identified by '45t3r15k' ;
lsim2
grant replication slave on *.* to 'rep1'@'67.217.39.114' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.115' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.117' identified by '45t3r15k' ;
grant replication slave on *.* to 'rep1'@'67.217.39.119' identified by '45t3r15k' ;


#run this on the new app server
grant replication slave on *.* to 'rep1'@'216.66.74.103' identified by '45t3r15k' ;
show master status ;
CHANGE MASTER TO MASTER_HOST='216.66.74.103', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;

slave start ;

########make sure to change the log pos and log file in both statements.
######## check the log files for any errors


#run this on the old app server
grant replication slave on *.* to 'rep1'@'67.217.39.98' identified by '45t3r15k' ;
show master status ;
CHANGE MASTER TO MASTER_HOST='67.217.39.98', MASTER_USER='rep1', MASTER_PASSWORD='45t3r15k', MASTER_LOG_FILE='mysql-bin.000035', MASTER_LOG_POS=299707666 ;

slave start ;

copy my.cnf from old app server to new one and change only the server-id column


