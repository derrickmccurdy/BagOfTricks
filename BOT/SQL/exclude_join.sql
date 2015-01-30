select chicago.* INTO OUTFILE '/tmp/missing_supportticketpriority.csv'  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' from support_chicago.supportticketpriority chicago  left outer join support.supportticketpriority naperville on chicago.ID = naperville.ID where naperville.ID is NULL ;

LOAD DATA LOCAL INFILE '/tmp/missing_supportticketpriority.csv'  INTO TABLE support.supportticketpriority FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' ;




select count(*)  from  t316_4a1591f07bcd1 as old left outer join t316_4a15b8804af54 as new on old.email_hash = new.email_hash where new.id is NULL ;
+----------+
| count(*) |
+----------+
|        0 | 
+----------+
1 row in set (5.55 sec)

mysql> select count(*)  from  t316_4a13ed7b2e1a1 as old left outer join t316_4a15b8804af54 as new on old.email_hash = new.email_hash where new.id is NULL ;
+----------+
| count(*) |
+----------+
|        0 | 
+----------+
1 row in set (13.65 sec)

