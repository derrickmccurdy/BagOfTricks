/*select weekofyear('2010-05-24'), weekday('2010-05-24'), date_format('2010-05-24','%Y-%m-%d %W') ;
+--------------------------+-----------------------+-----------------------------------------+
| weekofyear('2010-05-24') | weekday('2010-05-24') | date_format('2010-05-24','%Y-%m-%d %W') |
+--------------------------+-----------------------+-----------------------------------------+
|                       21 |                     0 | 2010-05-24 Monday                       | 
+--------------------------+-----------------------+-----------------------------------------+
select weekday(date_format(date_sub('2010-05-28', interval (weekday('2010-05-28')) day ),'%Y-%m-%d')) ; 
+------------------------------------------------------------------------------------------------+
| weekday(date_format(date_sub('2010-05-28', interval (weekday('2010-05-28')) day ),'%Y-%m-%d')) |
+------------------------------------------------------------------------------------------------+
|                                                                                              0 | 
+------------------------------------------------------------------------------------------------+
select @start_of_week := date_format(date_sub('2010-05-28', interval (weekday('2010-05-28')) day ),'%Y-%m-%d') as start, @end_of_week := date_format(date_add(@start_of_week, interval 7 day), '%Y-%m-%d') as end ; 
+------------+------------+
| start      | end        |
+------------+------------+
| 2010-05-24 | 2010-05-31 | 
+------------+------------+
*/
/*
select count(if(services.id_service is not null, services.id_service, accounts.emailmarketinginhouseenabled)) as service_count, sum(accounts.emailmarketinginhouseenabled) as INHOUSE, ifnull(services.title, "Total Inhouse or no services yet") as title from system.accounts as accounts left join system.services_accounts as sa on accounts.accountid = sa.accountid left join system.services as services on sa.id_service = services.id_service where accounts.dateadded >= '2010-06-07' and accounts.dateadded < '2010-06-14' group by services.id_service;
+---------------+---------+----------------------------------+
| service_count | INHOUSE | title                            |
+---------------+---------+----------------------------------+
|             3 |       1 | Total Inhouse or no services yet | 
|             6 |       0 | Email Marketing Simplicity       | 
+---------------+---------+----------------------------------+
We are getting the number of accounts that have no services yet or inhouse accounts in the first row. Subtract the number of inhouse accounts from service count in the first row to find the number of new accounts that have no services yet.
*/

