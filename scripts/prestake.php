<?php

$csv = array_map('str_getcsv', file('prestake.csv'));


foreach ($csv as $arr) {
    $url = "https://shibkingpro.org/prestake/stake?address=";
	$url .= $arr[0] . "&amount=" . $arr[1];
	var_dump($url);
	$res = file_get_contents($url);
	var_dump($res);
}


