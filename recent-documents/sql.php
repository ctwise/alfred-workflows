<?php
$database = $argv[1];
$sql = new SQLite3( $database );
$results = $sql->query("select path from recentdocs order by ts desc");

while( $result = $results->fetchArray( SQLITE3_ASSOC ) ):
	echo $result["path"] . "\n";
endwhile;

