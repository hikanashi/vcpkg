#Requires -Version 3.0

function Invoke-DownloadFile
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory,position=0)]
        [string]
        $target_url,

        [parameter(Mandatory,position=1)]
        [string]
        $file_path
    )

    
    # Create Empty File
    New-Item $file_path -type file -Force | Out-Null

    # get proxy enviroment
    $proxy = $env:HTTPS_PROXY

    if($proxy -ne $null)
    {
        $proxy_uri = New-Object System.Uri $proxy
        $proxy_url = $proxy_uri.Scheme + "://" + $proxy_uri.Authority
        if( $proxy_uri.UserInfo -ne "")
        {
            $proxy_splitpos = $proxy_uri.UserInfo.IndexOf(':')
            $proxy_username = $proxy_uri.UserInfo.Substring(0,$proxy_splitpos)
            $proxy_pass = $proxy_uri.UserInfo.Substring($proxy_splitpos+1)
        }
    }

    # Create WebClient
    $web_client = New-Object System.Net.WebClient

    # Setting Proxy
    if($proxy_url -ne "")
    {
        $proxy_server = New-Object System.Net.WebProxy($proxy_url, $true
        )
        if(($proxy_username -ne "") -And ($proxy_pass -ne ""))
        {
            $credential = New-Object System.Net.NetworkCredential($proxy_username, $proxy_pass)
            $proxy_server.Credentials = $credential
        }

        $web_client.Proxy = $proxy_server
    }

    # Start Download
    $web_client.DownloadFile($target_url, $file_path)
}

try
{
    if($args.count -lt 2)
    {
        throw "Not enough arguments"
    } 
    else
    {
        Invoke-DownloadFile $args[0] $args[1]
        exit 0
    }
}
catch
{
    Write-Host $error[0]
    Write-Host "`nUsage: <DownloadUrl> <SaveFilePath>"
    exit 1
}
