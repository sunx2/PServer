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
    [string] $query_path = "Query.json"
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
    start_url($html){
        $this.url = $html
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
                $html = $this.routes[$this.request_url]
                #prepare Query
                
                
                if($this.accept_query){
                    foreach($item in $this.request.Url.Query.Substring(1).Split('&') ){
                        $temp = $item.Split('=')
                        $this.queries.Add($temp[0],$temp[1])}   
                    [string[]]$q_array = $this.queries | out-string -stream
                        $a = Get-Content -Path $this.query_path
                        Set-Content -Path $this.query_path -Value "$($q_array)"
                }
                if($html -eq $null){
                    $this.response.StatusCode = 404
                    $html = $this.errrormsg
                }
                #if($this.request.HttpMethod=="POST"){if($this.response.StatusCode -eq 200){if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request_url) | 200 POST Success" -ForegroundColor Green }}  else {if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request_url) | 404 POST Error" -ForegroundColor Red }}}
                if($this.response.StatusCode -eq 200){if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request.url.LocalPath) | 200 $($this.request.HttpMethod) Success" -ForegroundColor Green }} else {if($this.logs){Write-Host "$(Get-Date): Request for route $($this.request.url.LocalPath) | $($this.response.StatusCode) $($this.request.HttpMethod) Error" -ForegroundColor Red }}
                
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
