-- create the new master table
CREATE TABLE `tblmaster_no_dups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listid` int(10) DEFAULT NULL,
  `email` varchar(200) NOT NULL,
  `email_hash` bigint(17) unsigned zerofill NOT NULL,
  `firstname` varchar(45) NOT NULL,
  `middlename` varchar(45) NOT NULL,
  `lastname` varchar(45) NOT NULL,
  `address` varchar(250) NOT NULL,
  `address2` varchar(250) NOT NULL,
  `city` varchar(95) NOT NULL,
  `county` varchar(100) NOT NULL,
  `region` varchar(25) NOT NULL,
  `zipcode` varchar(20) NOT NULL DEFAULT '0',
  `gender` varchar(5) NOT NULL,
  `companyname` varchar(45) NOT NULL,
  `jobtitle` varchar(45) NOT NULL,
  `industry` varchar(45) NOT NULL,
  `phonearea` varchar(3) NOT NULL,
  `phonenum` varchar(15) NOT NULL,
  `keywords` varchar(250) DEFAULT NULL,
  `born` date NOT NULL DEFAULT '0000-00-00',
  `source` varchar(250) NOT NULL,
  `dtTimeStamp` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dateadded` date NOT NULL DEFAULT '0000-00-00',
  `ip` int(10) unsigned NOT NULL DEFAULT '0',
  `domain` varchar(100) DEFAULT NULL,
  `exclude` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `Confirmed` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ConfirmedTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Opener` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `OpenerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Clicker` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerIP` int(10) unsigned NOT NULL DEFAULT '0',
  `ClickerTS` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `country_short` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_hash` (`email_hash`),
  KEY `company` (`companyname`),
  KEY `region` (`region`),
  KEY `zip` (`zipcode`),
  KEY `keywords` (`keywords`),
  KEY `country` (`country_short`)
) ENGINE=MyISAM AUTO_INCREMENT=82769274 DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC ;


--select the data out to the temp file
SELECT 
listid    
,LOWER(email) AS email      
,conv(substr(md5(LOWER(email)),19,32),16,10) AS email_hash  
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
INTO OUTFILE '/tmp/master_dedup.txt'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
FROM datastore.tblmaster ;


--Load the data from the temp file into the new table
LOAD DATA  INFILE '/tmp/master_dedup.txt' REPLACE INTO TABLE `tblmaster_no_dups`
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
listid    
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
,country_short ) ;


-- rename the two master tables
RENAME TABLE datastore.tblmaster TO datastore.tblmaster_dups,
datastore.tblmaster_no_dups TO datastore.tblmaster ;
