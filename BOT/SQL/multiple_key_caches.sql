-- http://dev.mysql.com/doc/refman/5.1/en/multiple-key-caches.html

-- /etc/my.cnf
key_buffer_size = 4G
hot_cache.key_buffer_size = 2G
cold_cache.key_buffer_size = 2G
init_file=/var/lib/mysql/mysqld_init.sql


-- /var/lib/mysql/mysqld_init.sql
CACHE INDEX db1.t1, db1.t2, db2.t3 IN hot_cache ;
CACHE INDEX db1.t4, db2.t5, db2.t6 IN cold_cache ;
-- http://dev.mysql.com/doc/refman/5.1/en/index-preloading.html
LOAD INDEX INTO CACHE db1.t1, db1.t2 IGNORE LEAVES ;

