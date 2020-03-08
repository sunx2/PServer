### Powershell server

Powershell server is a script which can used to make  a small server on powershell.

### Table of contents
* Import Server
* Basic server code
* Functions
	* <a href="#starturl">Start Url</a>
	*  <a href="#route">Url Routing</a>
	* <a href="#template">Local Tmplate</a>
	* <a href="#api">Api resource</a>
	* <a href="#exit">Quit Server Request </a>
	* <a href="#textformat">Text Formatting </a>

#### Import server
```powershell
Import-Module -Force "path\to\Sun.psm1"
```
####  basic server code
```powershell
$server = Server
$server.start_url("http://127.0.0.1:5000/")
$server.route('/' , "<b>welcome to my page</b>" , @{})
$server.start()
```
#### Error page
```powershell
$server.error_page("path/to/error.html")
```
#### functions


#####  <span name="starturl">Url selecting</span>
> Specifies a server url to start  the server
```powershell
$server.start_url("http://127.0.0.1:5000/")
```
##### <span name="route">Routing</span>
> Creates a new route.
> it only accepts text or html.
```powershell
$server.route('/hello/world' , "<b>hello world</b>" , @{})
```
##### <span name="template">Templating</span>
> Creates a new template.
> you have to specify the specific location of the file.
> ex: c://myfile.html
```powershell
$server.template('/hello/world' , "file.html" , @{})
```

##### <span name="api">API Resource</span>
> Creates a new api resource
> it only accepts text (you can use json like "{'hello':'world'}")
```powershell
$server.resource('/api/helloworld' , "{'hello':'world'}" , @{})
```

##### <span name="exit">API Resource</span>
> Creates a exit link which accepts a password to close the server
> bellow exmaple will make the server exit at /exit/terminate123
> It will ask for confirmation in console too.
> Default exit url is /quit/TERMINATE_SERVER_01 , if you dont specify any exit_server
```powershell
$server.exit_server("exit","terminate123")
```


### more functions coming.



### <span name="textformat">text formatting</span>
> formats text in template
> formats in template,string or resource
```powershell
$server.route('/' , "<b>welcome to my page %hello%</b>",@{hello="world"})
$server.template("/home/myexample" , "C:\Users\Sun\Documents\powershell\file.html",@{user="Sun"; hi="hello"})
$server.resource('/api' , "{'hello':'%world%'}",@{world="mouse"})
```

