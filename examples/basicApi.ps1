$server = Server
$server.start_url("http://127.0.0.1:8000/")
$server.resource("/","%data%",@{data='{name: Sun, date: 24 march}'}) 
$server.start() #sends data in api url 
