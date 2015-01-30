use emarketing ;

-- drop table if exists emarketing.paused_campaign_log ;

create table if not exists emarketing.paused_campaign_log (
id  int(10) auto_increment primary key, 
user_id int(10) not null default 0,
AccountID int(10) not null default 0,
camp_id int(10) not null default 0,
ip varchar(30) not null,
time_paused timestamp ) ;
 
drop trigger if exists emarketing.before_paused_campaign_log_trigger ;

delimiter ~

create trigger emarketing.before_paused_campaign_log_trigger before insert on emarketing.paused_campaign_log
for each row
begin
        set NEW.ip := inet_aton(NEW.ip) ;
end ;

~

delimiter ;
 
-- drop table if exists emarketing.online_purchase_log ;

create table if not exists emarketing.online_purchase_log (
id int(10) auto_increment primary key,
user_id int(10) not null default 0,
AccountID int(10) not null default 0,
-- need trigger to look this up
parentID int(10) not null default 0,
-- mabe trigger to convert this to int with inet_aton
ip int(10) not null default 0,
time_purchased timestamp default current_timestamp, 
time_charged timestamp default "0000-00-00 00:00:00" ,
list_code int(10) not null default 0,
num_of_records int(10) not null default 0,
price float(10,2),
transactionID bigint(17) unsigned zerofill,
-- system.services ID_SERVICE 31 for leased lists
ID_SERVICE int(10) not null default 0 ,
-- system.services_billing_item ID_BILLING_ITEM
ID_BILLING_ITEM int(10) not null default 0 ,
-- trigger
billing_attempts tinyint(3) unsigned not null default 0,
billing_status tinyint(3) unsigned not null default 0
)
;

drop trigger if exists emarketing.before_online_purchase_log_trigger ;
delimiter ~

create trigger emarketing.before_online_purchase_log_trigger before insert on emarketing.online_purchase_log
for each row
begin
	DECLARE dparentid int(10) default 0 ;
        set NEW.ip := inet_aton(NEW.ip) ;
	select ParentAccountID into dparentid from system.accounts where AccountID = NEW.AccountID ;
	set NEW.parentID := dparentid ;
end ;
~
delimiter ;


/*
describe system.services_billing_item ;
+--------------------+------------------+------+-----+---------+----------------+
| Field              | Type             | Null | Key | Default | Extra          |
+--------------------+------------------+------+-----+---------+----------------+
| ID_BILLING_ITEM    | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| AccountID          | int(10)          | NO   | MUL | 0       |                |
| ID_SERVICE         | int(10)          | NO   |     | 0       |                |
| DateAdded          | datetime         | YES  |     | NULL    |                |
| ManagerStatus      | tinyint(4)       | NO   |     | 0       |                |
| ManagerReason      | text             | YES  |     | NULL    |                |
| DateManager        | datetime         | YES  |     | NULL    |                |
| BillingStatus      | tinyint(4)       | NO   |     | 0       |                |
| BillingReason      | text             | YES  |     | NULL    |                |
| BillingDate        | datetime         | YES  |     | NULL    |                |
| Removed            | tinyint(4)       | YES  |     | 0       |                |
| RemovedReason      | text             | YES  |     | NULL    |                |
| Price              | decimal(8,2)     | YES  |     | 0.00    |                |
| ID_PAYMENT         | int(10)          | YES  |     | NULL    |                |
| OtherNotes         | text             | YES  |     | NULL    |                |
| ChargedByAccountID | int(10)          | YES  |     | 0       |                |
| IsPayment          | tinyint(1)       | YES  |     | 0       |                |
| ID_PROCESSOR       | int(10)          | YES  |     | 0       |                |
| BillingAccountID   | int(10)          | YES  | MUL | 0       |                |
| PayOutItemID       | int(10)          | YES  |     | 0       |                |
| ExtraDetailTitle   | tinytext         | YES  |     | NULL    |                |
| CreatedBy          | int(10)          | YES  |     | 0       |                |
| DateAddedSort      | tinytext         | YES  |     | NULL    |                |
+--------------------+------------------+------+-----+---------+----------------+
-- if we send data to system.services_billing_item, we need to record the ID_BILLING_ITEM

-- ChargedByAccountID =  userid
-- BillingAccountID - sticky - system.accounts
-- ExtraDetailTitle list name and code
-- CreatedBy = userid
*/
drop trigger if exists emarketing.after_online_purchase_log_trigger ;
delimiter ~

create trigger emarketing.after_online_purchase_log_trigger before update on emarketing.online_purchase_log
for each row
begin
-- 	lookup BillingAccountID
	DECLARE dBillingAccountID int(10) default 0 ;
	select BillingAccountID into dBillingAccountID from system.accounts where AccountID = OLD.AccountID ;
	set NEW.billing_attempts := OLD.billing_attempts + 1 ;
	if NEW.billing_attempts > 2
	then
		if OLD.billing_status = 0
		then
			set NEW.billing_status := 1 ;
		end if ;
	end if ;
	if NEW.billing_status = 1
	then
-- 		send the data to  system.services_billing_item
		insert into system.services_billing_item (managerstatus,AccountID, ID_SERVICE, DateAdded, Price, OtherNotes, ChargedByAccountID, BillingAccountID, ExtraDetailTitle, CreatedBy,DateAddedSort) values(1,OLD.AccountID, OLD.ID_SERVICE, now(), OLD.price, CONCAT("online_purchase_log id = ",OLD.id," list_code = ",OLD.list_code," num_of_records = ",OLD.num_of_records),OLD.user_id,dBillingAccountID,CONCAT("list_code = ",OLD.list_code),OLD.user_id, date_format(now(),'%Y-%m-%d')) ;
	end if ;
end ;

~

delimiter ;


