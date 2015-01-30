use datastore ;
drop event if exists copy_direct_optins ;
delimiter ~

CREATE EVENT `copy_direct_optins` ON SCHEDULE EVERY 1 DAY STARTS '2009-03-19 02:12:00' ON COMPLETION PRESERVE ENABLE COMMENT 'This event copies entries from datastore.tbldirect_optin to data' 
DO BEGIN
--        call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00") ;
        call datastore.suppression("datastore.tbldirect_optin", 1, "", "0000-00-00 00:00:00", 1, 1) ;
 
        insert low_priority ignore into datastore.tblmaster 
        (listid
        ,email
        ,email_hash
        ,firstname
        ,middlename
        ,lastname
        ,address
        ,address2
        ,city
        ,county
        ,region
        ,zipcode
        ,gender
        ,companyname
        ,jobtitle
        ,industry
        ,phonearea
        ,phonenum
        ,keywords
        ,born
        ,source
        ,dtTimeStamp
        ,dateadded
        ,ip
        ,domain
        ,exclude
        ,Confirmed
        ,ConfirmedIP
        ,ConfirmedTS
        ,Opener
        ,OpenerIP
        ,OpenerTS
        ,Clicker
        ,ClickerIP
        ,ClickerTS
        ,country_short) 
        select listid
        ,email
        ,email_hash
        ,firstname
        ,middlename
        ,lastname
        ,address
        ,address2
        ,city
        ,county
        ,region
        ,zipcode
        ,gender
        ,companyname
        ,jobtitle
        ,industry
        ,phonearea
        ,phonenum
        ,keywords
        ,born
        ,source
        ,dtTimeStamp
        ,dateadded
        ,ip
        ,domain
        ,exclude
        ,Confirmed
        ,ConfirmedIP
        ,ConfirmedTS
        ,Opener
        ,OpenerIP
        ,OpenerTS
        ,Clicker
        ,ClickerIP
        ,ClickerTS
        ,country_short 
        from datastore.tbldirect_optin where Status = 0 ; 

        truncate datastore.tbldirect_optin ; 
end ;
~

delimiter ;
