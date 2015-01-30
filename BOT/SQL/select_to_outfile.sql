select * INTO OUTFILE '/tmp/stevesavant2.txt'  
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' 
FROM datastore.tblmaster  
WHERE  (country_short = 'us' OR domain LIKE '%.us') AND firstname != "" and lastname != "" and address != "" and city != "" and region != "" and zipcode != "" and ip != "" and source != "" and dtTimeStamp != "" ;



select * INTO OUTFILE '/tmp/tim_list_maryland_optins.txt' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' FROM datastore.tblmaster WHERE  ip != "" and source != "" and dtTimeStamp != "" AND region IN('md') ;




select * INTO OUTFILE '/tmp/.csv'  FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' 




select Email, FirstName, LastName, Address, Address2, City, Region, Zip, Country, Phone into outfile '/tmp/newsletter.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' from leads.contact_forms where OrigAccountID = 2 and Email <> '' ;
