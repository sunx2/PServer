Import-Module -Force "Sun.psm1"   # path to the psm1 file

$server = Server
$server.start_url("http://127.0.0.1:8000/")
$server.route("/","Hello world",@{})   #homepage
$server.start()
