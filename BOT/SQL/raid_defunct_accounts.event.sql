/*

On App Server

select S.Rating, A.AccountID from system.accounts A inner join emarketing.settings S on A.AccountID = S.AccountID where A.DateDisabled is not null and A.DateDisabled < "2009-02-25 00:00:00" and A.DateDisabled > "2009-01-01 00:00:00" and S.Rating = "B" order by A.AccountID desc limit 20

On list servers....
describe datastore.masterimportarchive ;

+-------------+--------------+------+-----+-------------------+-----------------------------+
| Field       | Type         | Null | Key | Default           | Extra                       |
+-------------+--------------+------+-----+-------------------+-----------------------------+
| id          | int(11)      | NO   | PRI | NULL              | auto_increment              | 
| AccountID   | int(10)      | NO   |     | NULL              |                             | 
| filename    | varchar(255) | NO   |     | NULL              |                             | 
| importdate  | timestamp    | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP | 
| keywords    | varchar(255) | NO   | MUL | NULL              |                             | 
| description | varchar(255) | NO   |     | NULL              |                             | 
+-------------+--------------+------+-----+-------------------+-----------------------------+

Problem 1 is setting the date range to use in the app server query.


problem 2 is selecting the database and table names for that account.


Problem 3 is putting records into datastore.masterimportarchive on the master list server FROM the app server.
	This is the most daunting of the problems. The other two are mostly accademic.
	We need to make sure that we do not try to put more than one entry per account + table.
		To solve this problem, I can add a unique index on the accountID and filename


Advanced List Import Questions:

What is the amount of time we should wait before raiding defunct client data? 60 Days?

What is the minimum rating of defunct clients we should raid? B, C or D?
    We do not have a great deal of turnover of B clients, so I am leaning towards C. We could definitely START with B and have a good amount of data to process at the outset.

How do you feel about slaving the master list server to the main database in order to replicate two tables?
    The issue is that the settings and accounts tables are on the main database server and the masterimportarchive table is on the master list server.
    I propose to slave the master list server to the main database server for just those two tables (system.accounts and emarketing.settings). I CAN have ONLY those two tables replicated to the master list server from the main database server. That way, I can create a MySQL event on the master list server that reads the contents of those two tables once per day and creates new entries in datastore.masterimportarchive for processing into the master dataset. The alternative involves a cron job and shell script which I would rather avoid. There will be additional moving parts either way, but I think that the replication/event solution would be preferable in that it would at least limit the type of the moving parts to database moving parts. MySQL on the main list server would have to be restarted but the main database server would not. It would only have to have a new entry created in the mysql.users table with replicate slave permissions.



Provided all of the questions above have been answered, the mysql event would be as follows below:

Assumptions:
??????????We are replicating emarketing.settngs, system.accounts, and emarketing.lists from APP to MASTER.
We only want defunct accounts with A or B ratings.
We only want lists with higher than 15 recipients to avoid test lists.
An account is defunct once it has been disabled for 60 days.
We do not want inhouse accounts.(If we ever did, and an inhouse account MIGHT contain data that we would want, we just feed step 1 of the app the ListID number from emarketing.lists and go from there.)
We have updated datastore.masterimmportarchive and added a unique index on Accountid AND filename so that we never have the same list inserted into the table more than once.

*/
use datastore ;
drop event if exists raid_defunct_accounts ;
delimiter ~

CREATE EVENT raid_defunct_accounts ON SCHEDULE EVERY 1 DAY STARTS '2009-04-28 10:12:00' ON COMPLETION PRESERVE DISABLE ON SLAVE 
COMMENT 'This event reads system.Accounts and emarketing.settings to find defunct client accounts. When it finds them, it creates entries in datastore.masterimportarchive ready for processing by a user' 
DO 
BEGIN

	INSERT IGNORE INTO datastore.masterimportarchive (AccountID, filename, keywords, description, initial_records)
		select accounts.AccountID, lists.ID, "not_processed", lists.ListName, lists.total 
			FROM system.accounts accounts 
				INNER JOIN emarketing.settings settings ON accounts.AccountID = settings.AccountID
				INNER JOIN emarketing.lists lists ON settings.AccountID = lists.AccountID
			WHERE accounts.DateDisabled IS NOT NULL 
--				AND accounts.DateDisabled < DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY) 
				AND DATE_FORMAT(accounts.DateDisabled, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY), '%Y-%m-%d')
				AND (settings.Rating = "A" OR settings.Rating = "B")
				AND lists.total > 15
				AND accounts.EmailMarketingInhouseEnabled = 0
				AND lists.private = 0
				AND accounts.AccountEnabled = 0
				AND lists.ListType = "Email" ;
END ;
~
delimiter ;
/*
 describe datastore.masterimportarchive ;
+---------------------+--------------+------+-----+-------------------+-----------------------------+
| Field               | Type         | Null | Key | Default           | Extra                       |
+---------------------+--------------+------+-----+-------------------+-----------------------------+
| id                  | int(11)      | NO   | PRI | NULL              | auto_increment              | 
| AccountID           | int(10)      | NO   |     | NULL              |                             | 
| filename            | varchar(255) | NO   |     | NULL              |                             | 
| importdate          | timestamp    | NO   |     | CURRENT_TIMESTAMP | on update CURRENT_TIMESTAMP | 
| keywords            | varchar(255) | NO   | MUL | NULL              |                             | 
| description         | varchar(255) | NO   |     | NULL              |                             | 
| initial_records     | int(10)      | YES  |     | NULL              |                             | 


               select accounts.AccountID, lists.ID, "not_processed", lists.ListName, lists.total FROM system.accounts accounts INNER JOIN emarketing.settings settings ON Accounts.AccountID = settings.AccountID INNER JOIN emarketing.lists lists ON settings.AccountID = lists.AccountID WHERE accounts.DateDisabled IS NOT NULL AND accounts.DateDisabled < DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY) AND (settings.Rating = "A" OR settings.Rating = "B") AND lists.total > 15 AND accounts.EmailMarketingInhouseEnabled = 0 AND lists.ListType = "Email" ;

select accounts.AccountID, lists.ID, "not_processed", lists.ListName, lists.total
                        FROM system.accounts accounts
                                INNER JOIN emarketing.settings settings ON accounts.AccountID = settings.AccountID
                                INNER JOIN emarketing.lists lists ON settings.AccountID = lists.AccountID
                        WHERE accounts.DateDisabled IS NOT NULL
                              AND accounts.DateDisabled < DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY) 
--                                AND DATE_FORMAT(accounts.DateDisabled, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY), '%Y-%m-%d')
                                AND (settings.Rating = "A" OR settings.Rating = "B")
                                AND lists.total > 15
                                AND accounts.EmailMarketingInhouseEnabled = 0
                                AND lists.private = 0
                                AND accounts.AccountEnabled = 0
                                AND lists.ListType = "Email" ;



        INSERT IGNORE INTO datastore.masterimportarchive (AccountID, filename, keywords, description, initial_records)
                select accounts.AccountID, lists.ID, "not_processed", lists.ListName, lists.total
                        FROM system.accounts accounts
                                INNER JOIN emarketing.settings settings ON accounts.AccountID = settings.AccountID
                                INNER JOIN emarketing.lists lists ON settings.AccountID = lists.AccountID
                        WHERE accounts.DateDisabled IS NOT NULL
                              AND accounts.DateDisabled < DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY) 
--                                AND DATE_FORMAT(accounts.DateDisabled, '%Y-%m-%d') = DATE_FORMAT(DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY), '%Y-%m-%d')
                                AND (settings.Rating = "A" OR settings.Rating = "B")
                                AND lists.total > 15
                                AND accounts.EmailMarketingInhouseEnabled = 0
                                AND lists.private = 0
                                AND accounts.AccountEnabled = 0
                                AND lists.ListType = "Email" ;






*/

