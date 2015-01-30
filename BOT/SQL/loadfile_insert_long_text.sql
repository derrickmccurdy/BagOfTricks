
-- this is useful for loading a file's worth of text into a text field. No worries about quoting or escaping.

insert into system.terms_of_service (date,content) values(now(), load_file('/tmp/EMP-TOS.html')) ;
