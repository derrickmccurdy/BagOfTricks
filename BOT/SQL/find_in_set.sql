
-- opl.list_code_multi is a comma separated list of numbers. opl.list_code_multi is actually a text field. This accomplishes a one to many join of a text field to an integer id
select * from emarketing.online_purchase_log as opl inner join emarketing.precompiled_lists as precompiled on find_in_set(precompiled.id, opl.list_code_multi) ;
