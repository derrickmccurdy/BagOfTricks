
insert into emarketing.lists 
(
AccountID
,TableID
,ListName
,ListType
,Status
,TimeStarted
,TimeCompleted
,TimeLastSupressed
,timesUsed
,total
,active
,optout
,trash
,bounce
,private
,list_code
,num_loaded
,protected
,list_cost
,OrignalList
,autorenew
) 
select 
7700
,TableID
,ListName
,ListType
,Status
,TimeStarted
,TimeCompleted
,TimeLastSupressed
,0
,total
,active
,optout
,trash
,bounce
,private
,list_code
,num_loaded
,protected
,list_cost
,OrignalList
,autorenew
from emarketing.lists where AccountID = 7562 




| ID     | AccountID | TableID             | ListName | ListType | Status   | TimeStarted         | TimeCompleted       | TimeLastSupressed
   | timesUsed | total   | active | optout | trash | bounce | private | list_code | num_loaded | protected | list_cost | OrignalList | auto
renew |




insert into emarketing.lists ( AccountID ,TableID ,ListName ,ListType ,Status ,TimeStarted ,TimeCompleted ,TimeLastSupressed ,timesUsed ,total ,active ,optout ,trash ,bounce ,private ,list_code ,num_loaded ,protected ,list_cost ,OrignalList ,autorenew) select 7613 ,TableID ,ListName ,ListType ,Status ,TimeStarted ,TimeCompleted ,TimeLastSupressed ,0 ,total ,active ,optout ,trash ,bounce ,private ,list_code ,num_loaded ,protected ,list_cost ,OrignalList ,autorenew from emarketing.lists where TableName  like "ts%" and AccountID = 6383 ;



