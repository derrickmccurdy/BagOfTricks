-- USE datastore ;
-- bounces
-- DELETE m.* FROM datastore.tblmaster AS m INNER JOIN datastore.tblbounces AS b ON CONV(SUBSTR(MD5(LOWER(b.email)),19,32),16,10) = m.email_hash ;

-- individuals
DELETE m.* FROM datastore.tblmaster AS m INNER JOIN system.tblglobal_individual AS i ON CONV(SUBSTR(MD5(LOWER(i.email)),19,32),16,10) = m.email_hash ;

-- role
DELETE m.* FROM datastore.tblmaster AS m INNER JOIN system.tblglobal_role AS r ON m.email LIKE r.role_name ;

-- domain
DELETE m.* FROM datastore.tblmaster AS m INNER JOIN system.tblglobal_domains AS d ON m.domain LIKE d.domain_name ;


