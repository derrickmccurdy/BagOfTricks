
<?
// http://kevin.vanzonneveld.net/techblog/article/enhance_php_session_management/


/*
in php.ini or equivalent ...

session.save_handler = memcache
session.save_path = "tcp://127.0.0.1:11211"
*/


// http://us.php.net/manual/en/memcache.examples-overview.php
// or in your php file...
$session_save_path = "tcp://$host:$port?persistent=1&weight=2&timeout=2&retry_interval=10,  ,tcp://$host:$port  ";
ini_set('session.save_handler', 'memcache');
ini_set('session.save_path', $session_save_path);

?>

