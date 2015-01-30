-- You have to have the same full alias in the delete section as you have in the join section or this will not work.

delete  d6348.t6348_495011b4e02bc as c from d6348.t6348_495011b4e02bc as c inner join datastore.dups d on c.id = d.id

delete datastore.tblmaster as master from datastore.tblmaster as master inner joing system.tblglobal_role as role on master.email like role.role_name limit 0, 1000000;
