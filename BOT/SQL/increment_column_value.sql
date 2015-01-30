update t8155_4a53aba0dfcbc set unique_url = (select @dpid := @dpid + 1) ;
update t8155_4a53aba0dfcbc set unique_url = concat("http://www.surveyswitch.com/survey.php?t=e&v=394&pid=",`unique_url`) ;






update t8155_4a53aba0dfcbc set unique_url = if(@dpid is null,(select @dpid := 1), (select @dpid := @dpid + 1) ) ;

set @dip := 74.201.15.2 ;

