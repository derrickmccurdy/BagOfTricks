set group_concat_max_len = 8192 ;

select group_concat(AccountID separator ',')  from emarketing.settings where ListServer = "67.217.39.101" and AccountID <> 7613;
