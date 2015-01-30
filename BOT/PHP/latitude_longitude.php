<?
function findAllByD($x, $y, $distance = null, $day, $recursive) {
.....
$x2 = "`TblClassLocation`.`classLocationLong`";
$y2 = "`TblClassLocation`.`classLocationLat`";

return $this->find('all',array(
'limit'=>'1000',
'order'=>'distance ASC',
'fields'=>"
*,
(3958 * 3.1415926 * SQRT(({$y2} - {$y}) * ({$y2} - {$y}) + COS({$y2} /
57.29578) * COS({$y} / 57.29578) * ({$x2} - {$x}) * ({$x2} - {$x})) /
180)
AS distance",
'conditions'=>"
1=1
HAVING distance <= {$distance}

?>
