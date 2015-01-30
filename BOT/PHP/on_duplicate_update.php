<?

//This needs to bo into the advanced import tool.

$query =
        "INSERT IGNORE INTO ".TABLE_TURD_MASTER." ".
        "SELECT * FROM ".TABLE_TURD_IMPORT." AS src ".
        "ON DUPLICATE KEY UPDATE ";

foreach ($import_fields as $field) {
        if ($field != 'email') {
                $query .= TABLE_TURD_MASTER.".$field = IF( VALUES($field) != '', VALUES($field), ".TABLE_TURD_MASTER.".$field ), ";
        }
}
?>
