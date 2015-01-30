+---------------------------+
| Tables_in_system          |
+---------------------------+
| tblglobal_domains         |
| tblglobal_faxindividuals  |
| tblglobal_individual      |
| tblglobal_individual_bk   |
| tblglobal_individual_temp |
| tblglobal_role            |
| tblglobal_sms             |
| tblglobal_sms_role        |
+---------------------------+




delimiter |

CREATE DEFINER=`admin`@`%` TRIGGER suppress_domain AFTER INSERT ON tblglobal_domains
FOR EACH ROW
BEGIN
        DELETE FROM datastore.tblmaster where domain = NEW.domain_name ;
END 



CREATE DEFINER=`admin`@`%` TRIGGER suppress_individual AFTER INSERT ON tblglobal_individual
FOR EACH ROW
BEGIN
        DELETE FROM datastore.tblmaster where email_hash = conv(substr(md5(NEW.email),19,32),16,10) LIMIT 1 ;
END 




CREATE DEFINER=`admin`@`%` TRIGGER suppress_role AFTER INSERT ON tblglobal_role
FOR EACH ROW
BEGIN
-- not too sure about this
        DELETE FROM datastore.tblmaster where email LIKE  "`NEW.role_name`" ;
END 

CREATE DEFINER=`admin`@`%` TRIGGER suppress_domain AFTER INSERT ON tblglobal_domains
FOR EACH ROW
BEGIN
--        DELETE FROM tblmaster where email_hash = conv(substr(md5(NEW.email),19,32),16,10) LIMIT 1 ;
        DELETE FROM datastore.tblmaster where domain = NEW.domain_name ;
END 

CREATE DEFINER=`admin`@`%` TRIGGER suppress_domain AFTER INSERT ON tblglobal_domains
FOR EACH ROW
BEGIN
--        DELETE FROM tblmaster where email_hash = conv(substr(md5(NEW.email),19,32),16,10) LIMIT 1 ;
        DELETE FROM datastore.tblmaster where domain = NEW.domain_name ;
END 

delimiter ;


