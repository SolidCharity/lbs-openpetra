<?php
@include '/root/.ssh/github_config.php';

$url = "https://api.github.com";
date_default_timezone_set('Europe/Brussels');

# get all repos of user
if (false) {

$opts = array('http' =>
    array(
        'method'  => 'GET',
        'header'  => 
                     'User-Agent: MyClient'."\r\n".
                     'Authorization: Basic '.base64_encode($user.":".$token)."\r\n".
                     'Accept: application/vnd.github.v3+json',
    )
);
// print_r($opts);
$context = stream_context_create($opts);
$requesturl = $url."/users/tpokorra/repos";
if (($result = file_get_contents($requesturl, false, $context)) === false) {
	echo "Problem"."\n";
	var_dump($http_response_header);
	echo "\n";
	die();
}
echo print_r(json_decode($result),true);
}

if (true) {
# show all releases
$opts = array('http' =>
    array(
        'method'  => 'GET',
        'header'  =>
                      'User-Agent: MyClient'."\r\n".
                      'Authorization: Basic '.base64_encode($user.":".$token)."\r\n".
                     'Accept: application/vnd.github.v3+json',
    )
);
$context = stream_context_create($opts);
$requesturl = $url."/repos/openpetra/openpetra-nightlydevzip/releases";
if (($result = file_get_contents($requesturl, false, $context)) === false) {
  echo "Problem"."\n";
  var_dump($http_response_header);
        echo "\n";
        die();
}
$result = json_decode($result);
#echo print_r($result,true);
}

if (true) {
# delete a release
$releaseId = "1616067";
$releaseId = $result[0]->id;
$conn=curl_init();
curl_setopt($conn, CURLOPT_CUSTOMREQUEST, 'DELETE');
curl_setopt($conn, CURLOPT_USERAGENT, "myClient");
curl_setopt($conn, CURLOPT_URL, $url."/repos/openpetra/openpetra-nightlydevzip/releases/$releaseId");
curl_setopt($conn, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($conn, CURLOPT_HTTPHEADER, array(
    'Authorization: Basic '.base64_encode($user.":".$token))
);
$result = curl_exec($conn);
curl_close($conn);
#echo $result."\n";
}


if (true) {
# create a new release
# see https://developer.github.com/v3/repos/releases/
$query_string = "";

$zipname = "openpetra_development_".date("Y-m-d");
$tagname = date("Y-m-d");
$values = array( "tag_name" => $tagname,
        "prerelease" => "true",
        "target_commitish" => "master"
    );
$data_string = json_encode($values);
$conn=curl_init();
curl_setopt($conn, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($conn, CURLOPT_USERAGENT, "myClient");
curl_setopt($conn, CURLOPT_URL, $url."/repos/openpetra/openpetra-nightlydevzip/releases");
curl_setopt($conn, CURLOPT_POSTFIELDS, $data_string);
curl_setopt($conn, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($conn, CURLOPT_HTTPHEADER, array(
    'Content-Type: application/json',
    'Authorization: Basic '.base64_encode($user.":".$token),
    'Content-Length: ' . strlen($data_string))
);
$result = curl_exec($conn);
curl_close($conn);
$result = json_decode($result);
#echo print_r($result, true)."\n";
$id = $result->id;
$upload_url = $result->upload_url;
# now upload the zip file
$conn=curl_init();
$data_string = file_get_contents('/root/tarball/'.$zipname.'.zip');
$upload_url = str_replace('{?name}', '?name='.$zipname.'.zip', $upload_url);
echo "uploading to ".$upload_url."...\n";
curl_setopt($conn, CURLOPT_CUSTOMREQUEST, 'POST');
curl_setopt($conn, CURLOPT_USERAGENT, "myClient");
curl_setopt($conn, CURLOPT_URL, str_replace('{?name}', '?name='.$zipname.'.zip', $upload_url));
curl_setopt($conn, CURLOPT_TIMEOUT, 10*60); // seconds
curl_setopt($conn, CURLOPT_BINARYTRANSFER, TRUE);
curl_setopt($conn, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($conn, CURLOPT_HTTPHEADER, array(
    'Content-Type:application/octet-stream',
    'Content-Length: ' . strlen($data_string),
    'Authorization: Basic '.base64_encode($user.":".$token))
);
#$result = curl_exec($conn);
#curl_close($conn);
#echo $result."\n";
#echo print_r(json_decode($result),true)."\n";
$cmd = 'curl --silent -XPOST -H "Authorization: Basic '.base64_encode($token).'" -H "Content-Type:application/octet-stream" --data-binary @/root/tarball/'.$zipname.'.zip '.$upload_url;
exec($cmd,$result);
#echo print_r($result,true)."\n";
}


?>

