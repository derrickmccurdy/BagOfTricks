select count(*) FROM datastore.tblmaster 
where companyname != "" 
AND substr(`domain`,1,instr(`domain`,'.')-1) IN(replace(trim(`companyname`),' ','')) ;
