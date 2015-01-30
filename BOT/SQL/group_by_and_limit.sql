-- how do I get $x number of most recent records from a table for an indetirminant number of users

-- original query
select sw.userid, CONCAT(u.firstname, ' ', u.lastname) as username, a.AccountID, a.AccountName, sw.reason, DATE_FORMAT(sw.date, '%m/%d/%y at %h:%i %p') AS date, TIME_FORMAT(TIMEDIFF(NOW(), sw.date), "%j days, %h hours, %i minutes ago")  from system.account_switches sw inner join system.accounts a on sw.accountid = a.accountid inner join system.users u on sw.userid = u.userid order by sw.userid, sw.date desc;


select sw.userid
	, CONCAT(u.firstname, ' ', u.lastname) as username
	, a.AccountID, a.AccountName
	, sw.reason
from system.account_switches as sw 
	inner join system.accounts a on sw.accountid = a.accountid 
	inner join system.users u on sw.userid = u.userid 
order by sw.userid, sw.date desc;


-- from mysql docs http://dev.mysql.com/doc/refman/5.0/en/user-variables.html search Posted by Nicholas Bernstein on July 7 2006 7:23pm

select
t.ID,
t.TIMESTAMP,
@running:=if(@previous=t.ID,@running,0)+t.NUM as TOTAL,
@previous:=t.ID from (
select
ID,
TIMESTAMP,
count(*) as NUM
from HISTORY
group by ID, TIMESTAMP
order by ID, TIMESTAMP
)
as t;



-- select if(null = @prev_userid, userid into @prev_userid ,if(@prev_userid <> userid, (userid into @prev_userid, 0 into @per_user_count), )),userid, username, accountid, accountname, reason from (
select 
	@per_user_count := if(@prev_userid <> inner_query.userid, 0, @per_user_count) as per_user_count
	, @prev_userid := if(@prev_userid <> inner_query.userid, inner_query.userid, inner_query.userid ) as prev_userid
	, inner_query.userid as userid
	, inner_query.username as username
	, inner_query.accountid as accountid
	, inner_query.accountname as accountname
	, inner_query.reason as reason
	from (
		select
			if(21 > @per_user_count, null, sw.userid ) as userid
			, if(21 > @per_user_count, null, CONCAT(u.firstname, ' ', u.lastname)) as username
			, if(21 > @per_user_count, null, a.accountid) as accountid
			, if(21 > @per_user_count, null, a.accountname ) as accountname
			, if(21 > @per_user_count, null, sw.reason ) as reason
			, @per_user_count := @per_user_count + 1 as per_user_count
		from system.account_switches as sw  
			inner join system.accounts as a on sw.accountid = a.accountid 
			inner join system.users as u on sw.userid = u.userid 
		order by sw.userid, sw.date desc
	) as inner_query 
having per_user_count < 21
;


select 
--	@per_user_count := if(@prev_userid <> inner_query.userid, 0, @per_user_count) as per_user_count
--	, @prev_userid := if(@prev_userid <> inner_query.userid, inner_query.userid, inner_query.userid ) as prev_userid
--	 inner_query.userid as userid
--	, inner_query.username as username
--	, inner_query.accountid as accountid
--	, inner_query.accountname as accountname
--	, inner_query.reason as reason
	*
	from (
		select
			if(20 > @per_user_count, null, sw.userid ) as userid
			, if(20 > @per_user_count, null, CONCAT(u.firstname, ' ', u.lastname)) as username
			, if(20 > @per_user_count, null, a.accountid) as accountid
			, if(20 > @per_user_count, null, a.accountname ) as accountname
			, if(20 > @per_user_count, null, sw.reason ) as reason
--			, @per_user_count := @per_user_count + 1 as per_user_count
			, @per_user_count := if(@prev_userid <> sw.userid, 1, @per_user_count + 1) as per_user_count
			, @prev_userid := if(@prev_userid <> sw.userid, sw.userid, @prev_userid ) as prev_userid
		from system.account_switches as sw  
			inner join system.accounts as a on sw.accountid = a.accountid 
			inner join system.users as u on sw.userid = u.userid 
--		having per_user_count < 21
		order by sw.userid, sw.date desc
	)
 as inner_query 
 having per_user_count < 21
;



-- THIS is the answer.
select 
	id
	, userid
	, username
	, accountid
	, accountname
	, reason
	, per_user_count
	, sw_date
	from (
		select
			sw.id as id
			, sw.userid  as userid
			, CONCAT(u.firstname, ' ', u.lastname) as username
			, a.accountid as accountid
			, a.accountname as accountname
			, sw.reason as reason
			, sw.date as sw_date
			, @per_user_count := if(@prev_userid <> sw.userid, 1, @per_user_count + 1) as per_user_count
			, @prev_userid := if(@prev_userid <> sw.userid, sw.userid, @prev_userid ) as prev_userid
		from system.account_switches as sw  
			inner join system.accounts as a on sw.accountid = a.accountid 
			inner join system.users as u on sw.userid = u.userid 
		order by sw.userid asc, sw.date desc
	)
 as inner_query 
 having per_user_count < 21
;


