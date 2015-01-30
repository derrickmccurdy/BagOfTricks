<?
        $ddb_main = new Database();
        $ddb_main->setQuery("SELECT ParentAccountID FROM system.accounts WHERE AccountID = ".$_REQUEST['accountid']) ;
        $ddb_main->connect(MAIN_APP_SERVER, TURD_USER, TURD_PASS, "system");
        $ddb_main->setTable("accounts") ;
        $ddcount = $ddb_main->getRow("*",true,true) ;
        $ddb_main->close() ;
        //error_log("EEEEEEEEEEEEEEEEEEE".serialize($ddcount)) ;//[20-Oct-2008 14:58:37] EEEEEEEEEEEEEEEEEEEa:1:{s:15:"ParentAccountID";s:1:"2";}
?>
