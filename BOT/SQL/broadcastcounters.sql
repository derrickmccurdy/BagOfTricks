/*select s.AccountID, count(c.StatusInt) as running, s.BroadcastCounter, s.MaxBroadcastCounter, s.BusinessName, s.BroadcastServer,s.BoundIP, s.ListServer 
from emarketing.settings as s 
inner join system.accounts as a on s.AccountID = a.AccountID 
inner join emarketing.campaigns as c on a.AccountID = c.AccountID 
where c.endtime is null and c.starttime is not null and c.removed = 0 and a.emailmarketingenabled = '1' and a.accountenabled = '1' and a.loginenabled = '1' and s.broadcastcounter <= 0 and s.contractedamount > 0 and s.AccountID <> 737 and a.PastDueDays <= 5 and c.removed =0 and c.StatusInt in('400','200','500','600',"1000") 
group by s.AccountID ;








select s.AccountID, a.PastDueDays, s.BroadcastCounter, s.MaxBroadcastCounter, s.BusinessName, s.BroadcastServer,s.BoundIP, s.ListServer 
from emarketing.settings as s 
inner join system.accounts as a on s.AccountID = a.AccountID 
inner join emarketing.campaigns as c on a.AccountID = c.AccountID 
where c.endtime is null and c.starttime is not null and c.removed = 0 and a.emailmarketingenabled = '1' and a.accountenabled = '1' and a.loginenabled = '1' and s.broadcastcounter <= 0 and s.contractedamount > 0 and s.AccountID <> 737 and a.PastDueDays <= 5 
group by s.AccountID ;

*/




use emarketing ;

drop trigger if exists emarketing.counter_sink ;

delimiter ~

create trigger emarketing.counter_sink after update on emarketing.settings
	for each row
	begin
		if NEW.BroadcastCounter <> OLD.BroadcastCounter
		THEN
			update emarketing.shared_server_broadcasters set broadcasters = NEW.BroadcastCounter where AccountID = NEW.AccountID;
		END IF ;
		if NEW.MaxBroadcastCounter <> OLD.MaxBroadcastCounter
		THEN
			update emarketing.shared_server_broadcasters set  maxbroadcasters = NEW.MaxBroadcastCounter where AccountID = NEW.AccountID;
		END IF ;
	end ;
~
delimiter ;


drop trigger if exists emarketing.counter_sink_shared ;

delimiter ~

create trigger emarketing.counter_sink_shared after update on emarketing.shared_server_broadcasters
	for each row
	begin
		if NEW.broadcasters <> OLD.broadcasters
		THEN
			update emarketing.settings set BroadcastCounter = NEW.broadcasters where AccountID = NEW.AccountID;
		END IF ;
		if NEW.maxbroadcasters <> OLD.maxbroadcasters
		THEN
			update emarketing.settings set  MaxBroadcastCounter = NEW.maxbroadcasters where AccountID = NEW.AccountID;
		END IF ;
	end ;
~
delimiter ;

