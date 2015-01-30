use workorders ;

drop table if exists workorders.work_orders ;



create table workorders.work_orders (
	id int(10)  not null auto_increment primary key comment "internal primary key ID", 
	wotype enum("Email","Software") not null default "Email",
	accountid int(10) not null comment "AccountID of the client",
	updated timestamp comment "date and time record was last updated",  
	updated_by int(10) default 0 not null comment "User ID of last user to alter this work order",
	created timestamp comment "date and time record was created, filled by trigger workorders.before_insert_work_orders",
	deadline datetime comment "date and time work must be completed",
	manager_approved int(10) comment "Which manager approved work order",
	no_of_emails int(10) comment "number of emails to be sent on campaign",
	list_requirements varchar(250) comment "list codes or list ID numbers or list name of lists campaign is to be sent to",
	contracted_amount float(5,2) comment "amount of money client agreed to pay for campaign or service - this is the amount to bill the client's account",
	account_manager int(10) comment "account ID of account rep to whom this client belongs",
	contact_name varchar(200) comment "Contact name of client",
	phone varchar(25) comment "Contact phone number of client",
	email varchar(100) comment "Contact email address of client",
	company_name varchar(200) comment "Company name of client's employer",
	address1 varchar(150) comment "Address line one of client's employer",
	address2 varchar(150) comment "Address line two of client's employer",
	from_name varchar(200) comment "Who the email is from in the campaign",
	subject_line varchar(250) comment "Subject line of campaign",
	message_design tinyint(4) default 0 not null comment "Whether of not we are designing the message for the client",
	other_info text comment "Miscellaneous notes regarding the campaign, list, client, etc.",
	campaign_id int(10) comment "ID of the campaign set up for the client",
	campaign_name varchar(100) comment "Name of the campaign as client will see it in campaign results",
	billing tinyint(4) default 0 not null comment "Whether or not client account has been billed for this service",
	status enum("","Content","Tested","Approved", "Complete") not null default "" comment "Current status of the work order.",
	username varchar(50) comment "username of the client used to log in",
	password varchar(50) comment "Passwod of the client used to log in - This SHOULD be encrypted" ,
	removed tinyint(4) not null default 0 comment "whether of not this work order should be displayed at all",
	domain_name_requested varchar(200) comment "Domain name requested for profile",
	account_setup_by int(10) not null default 0 comment "Account rep who set up the account"

)
;

drop trigger if exists workorders.before_insert_work_orders ;

delimiter ~

create trigger workorders.before_insert_work_orders before insert on workorders.work_orders
for each row
begin

	set NEW.created := now() ;

end ;

~

delimiter ;




