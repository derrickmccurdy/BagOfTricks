create table if not exists leads.contact_log (
id int(10) auto_increment primary key,
lead_id int(10) not null ,
contact_time timestamp default current_timestamp,
status varchar(30) not null
) ;
