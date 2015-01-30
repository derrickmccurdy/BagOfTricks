insert into datastore.domain_lookup 
(domain_name, 
reverse_domain, 
date_added, 
last_updated, 
status, 
domain_hash) 

values

(
"derrick.com",
"moc.kcirred", 
now(),
now(),
@status := "good",
conv(substr(md5(lower("derrick.com")),19,32),16,10)
)
,
("derrick.com",
"moc.kcirred", 
now(),
now(),
@status := "bad",
conv(substr(md5(lower("derrick.com")),19,32),16,10)
) 
on duplicate key update last_updated = now(), status = @status ;
