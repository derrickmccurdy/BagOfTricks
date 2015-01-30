SELECT 'X' as flag, settings.accountid as AccountID, accounts.PastDueDays, settings.BusinessName, settings.BroadcastCounter, settings.maxbroadcastcounter, concat('X ',count(campaigns.statusint)) as consumed_broadcasters, settings.BroadcastServer, settings.BoundIP, settings.ListServer
FROM 
        emarketing.settings as settings inner join  system.accounts as accounts on settings.accountid = accounts.accountid INNER JOIN emarketing.campaigns as campaigns ON settings.accountid = campaigns.accountid
WHERE 
        accounts.accountenabled = 1 
        and accounts.emailmarketingenabled = 1
        AND accounts.loginenabled = 1 
        and accounts.PastDueDays <= 5
        and campaigns.statusint in('0','','100','200','1000')
        and campaigns.removed = 0
        and campaigns.schedule < date_sub(now(), interval 3 hour)
        AND settings.accountid not in(" . DEMOACCOUNT_ID. ",737) 
group by accounts.accountid
having count(campaigns.statusint in('400','500','600') ) < 1
ORDER BY campaigns.schedule DESC ;

