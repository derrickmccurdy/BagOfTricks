SET @CUST := 100001 ;
SET @FILE := '/home01/derrick/LISTS/homebiz_coreg-6-19-08-6.txt';
SET @DESCRIPTION := 'Kombol List' ;
SET @KEYWORDS := '' ;




INSERT INTO masterimportarchive (custid,filename,importdate,keywords,description) VALUES (100001,@FILE,NOW(),@KEYWORDS,@DESCRIPTION) ;


LOAD DATA LOCAL INFILE @FILE IGNORE INTO TABLE `tblmastertmp` 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' 
-- IGNORE 1 LINES 
(
firstname, 
lastname, 
address, 
city, 
region,
zipcode, 
companyname, 
email, 
phonenum, 
fax, 
dtTimeStamp, 
ip, 
source
) 
SET
dateadded = CURRENT_DATE,
custid = @CUST ;

LOAD DATA LOCAL INFILE '/tmp/6739_unsubscribe.txt' IGNORE INTO TABLE d6940.unsubscribe FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' (email, tsAdded) ;

mysql -e "load data infile '/home/derrick/Desktop/domains.txt' ignore into table system.tblglobal_domains fields terminated by ',' optionally enclosed by '"' lines terminated by '\n' (domain_name)" -u admin -p -h master


load data local infile '/tmp/10399_unsub_2.csv' INTO TABLE d10399.unsubscribe FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' (email, @ddemail_hash) set email_hash = datastore.email_hash(@ddemail_hash), tsadded = now() ;


load data local infile '/tmp/21635-1284747891.csv' IGNORE INTO TABLE d10264.t10264_aslakjfw FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' (@id,@listid,@email,@email_hash,@firstname,@middle,@lastname,@address,@address2,@city,@county,@region,@zipcode,@gender,@companyname,@jobtitle,@industry,@phonearea,@phonenum,@keywords,@born,@source,@dtTimeStamp,@dateadded,@ip,@domain,@exclude,@Confirmed,@ConfirmedIP,@Confirmedts,@Opener,@OpenerIP,@Openerts,@Clicker,@Clickerip,@Clickerts,@country_short) set email := @email,email_hash := @email_hash,firstname := @firstname,middlename := @middle,lastname := @lastname,address := @address,address2 := @address2,city := @city,county := @county,region := @region,zipcode := @zipcode,gender := @gender,companyname := @companyname,jobtitle := @jobtitle,industry := @industry,phonenum := @phonenum,born := @born,source := @source,ip := @ip,domain := @domain ;

