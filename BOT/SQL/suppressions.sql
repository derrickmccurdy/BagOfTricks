-- Copy suppression tables from 209.8.109.177 to 209.8.109.203:system


-- make so that copied tables are replicated

-- alter system files to reference tables at new location


-- SUPPRESSION trigger on tables at new location
-- there are three types of suppressions: Role, email, and domain.
-- need to look at queries to see how each of those suppression types is actually run.

DELIMITER |

--	suppression_table_name
SET @suppression_table_name := tblsuppressions ;
CREATE TRIGGER suppressor AFTER INSERT ON tblsuppressions ;
FOR EACH ROW
BEGIN
        DELETE FROM tblmaster where email_hash = conv(substr(md5(NEW.email),19,32),16,10) LIMIT 1 ;

END ; |


DELIMITER ;








-- BOUNCE REMOVAL


DELIMITER |
-- instead of email, I need to run the md5 algo on the address and match to the email_hash column since that is indexed.
CREATE TRIGGER bounce_removal AFTER INSERT ON tblbounces
FOR EACH ROW
BEGIN
        DELETE FROM tblmaster where email_hash = conv(substr(md5(NEW.email),19,32),16,10) LIMIT 1 ;

END ; |



DELIMITER ;

