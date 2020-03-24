$server = Server
$server.start_url("http://127.0.0.1:8000/")
$myfilelist = ls | ConvertTo-Html  #makes html from your current files
$server.route("/",$myfilelist,@{})  #shows all files in http://127.0.0.1:8000/
$server.start()
