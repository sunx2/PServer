$Query_Contexts = @{}
class Create_Server {
    [string] $url = "http://127.0.0.1:8080/"
    [Hashtable] $routes = @{}
    [hashtable] $queries = @{}
    [System.Net.HttpListener] $server 
    [System.Net.HttpListenerContext] $context 
    [System.Net.HttpListenerRequest] $request 
    [System.Net.HttpListenerResponse] $response 
    [string] $request_url = ''
    [byte[]] $buffer = $null
    [string] $errrormsg ="404 not found"
    [bool] $logs = $true
    [bool] $accept_query = $false
    [string] $query_path = ""
    [string] $files =''
    [hashtable] $filetypes = @{}
    [string] $quit_server = "quit"
    [string] $quit_code = "TERMINATE_SERVER_01"

    route($url,$responsetext,$dict=@{}){
        $get_text = "GET {0}" -f $url
        $parsedText = $this.Merger($responsetext,$dict)
        $this.routes.Add($get_text,$parsedText)
        
    }
    resource($url,$responsetext,$dict=@{}){
        $get_text = "POST {0}" -f $url
        $parsedText = $this.Merger($responsetext,$dict)
        $this.routes.Add($get_text,$parsedText)
    }
    [Hashtable]contexts(){
        return $this.queries
    }
    start_url($html){
        $this.url = $html
    }
    exit_server($quit_server , $code){
        $this.quit_code = $code
        $this.quit_server = $quit_server
    }
    set_logs($text){
        $this.logs = $text
    }
    get_query($text,$path){
        $this.accept_query = $text
        $this.query_path = $path
    }
    template($url,$reponsefile,$dict=@{}){
        $a = Get-Content $reponsefile 
        $get_text = "GET {0}" -f $url
        $parsedText = $this.Merger($a,$dict)
        $this.routes.Add($get_text,$parsedText)
    }
    Content($html){
         $this.buffer = [Text.Encoding]::UTF8.GetBytes($html)
    }
    serve_file($url,$reponsefile,$type){
        $a = Get-Content $reponsefile 
        $get_text = "GET {0}" -f $url
        $this.routes.Add($get_text,$a)
        $this.files+="{}$($get_text)"
        $this.filetypes.Add($get_text , $type)   
    }
    error_page($html){
        $a = Get-Content $html
        $this.errrormsg = $a
    }
    [string]Merger($html,$liststring){
        return [regex]::Replace(
        $html,
        '\%(?<tokenName>\w+)\%',
        {  
            param($match)

            $tokenName = $match.Groups['tokenName'].Value

            return $liststring[$tokenName]
        }) 
    }
    insertion($fun){
        $fun
    }

    start(){
        $this.server = New-Object System.Net.HttpListener
        $this.server.Prefixes.Add($this.url)
        $this.server.Start()
        if($this.server.IsListening -eq $this.logs){Write-Host "Server: Listening on $($this.url)" -ForegroundColor DarkRed -BackgroundColor White ; Write-Host "Activity: " -ForegroundColor Yellow}
        try{
            while ($this.server.IsListening){
                $this.context = $this.server.GetContext()
                $this.response = $this.context.Response
                $this.request = $this.context.Request
                #Write-Host $this.request.Headers
                $this.request_url = '{0} {1}' -f $this.request.HttpMethod,$this.request.url.LocalPath
                $this.response.StatusCode = 200

                #check for quit requests
                if($this.request.Url.LocalPath.Split('/')[1] -eq $this.quit_server){
                    Write-Host "Quit Request Recieved " -BackgroundColor White -ForegroundColor Red 
                    if($this.quit_code -eq $this.request.Url.LocalPath.Split('/')[2] ){
                        Write-Host "Terminate server (y/n): " -ForegroundColor Red -NoNewline
                        $a = Read-Host 
                        if($a -eq "y"){
                            break
                        }
                    }
                }
                $html = $this.routes[$this.request_url]
                #prepare Query
                
                
                if($this.accept_query){
                    foreach($item in $this.request.Url.Query.Substring(1).Split('&') ){
                        $temp = $item.Split('=')
                        $this.queries.Add($temp[0],$temp[1])}   
                    #[string[]]$q_array = $this.queries | out-string -stream
                        #$a = Get-Content -Path $this.query_path
                        #Set-Content -Path $this.query_path -Value "$($q_array)"
                        $Query_Contexts = $this.queries 
                }
                if($html -eq $null){
                    $this.response.StatusCode = 404
                    $html = $this.errrormsg
                } 
                #if($this.request.HttpMethod=="POST"){if($this.response.StatusCode -eq 200){if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request_url) | 200 POST Success" -ForegroundColor Green }}  else {if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request_url) | 404 POST Error" -ForegroundColor Red }}}
                if($this.response.StatusCode -eq 200){if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request.url.LocalPath) | 200 $($this.request.HttpMethod) Success" -ForegroundColor Green }} else {if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request.url.LocalPath) | $($this.response.StatusCode) $($this.request.HttpMethod) Error" -ForegroundColor Red }}
                $filestring = $this.files -split '{}'
                if($this.request_url -in $filestring){
                    $this.response.ContentType = $this.filetypes[$this.request_url]
                }
                $bufferhtml = [Text.Encoding]::UTF8.GetBytes($html)
                $this.response.ContentLength64 = $bufferhtml.length
                $this.response.OutputStream.Write($bufferhtml , 0 , $bufferhtml.length )
                $this.response.Close()
            }
        }
    catch{
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        "Error at {0} : {1}" -f $FailedItem,$ErrorMessage 
        }
    finally{
        Write-Host "$(Get-Date) : Server terminated" -ForegroundColor DarkRed -BackgroundColor White
        $this.server.Stop()   
        }   

    }


}

function Server {
    return [Create_Server]::new()
}

Export-ModuleMember -Function Server
Export-ModuleMember -Variable $Query_Contexts
