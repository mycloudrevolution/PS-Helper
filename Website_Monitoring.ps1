##############################################################################
##
## Website Availability Monitoring
## Created by Sravan Kumar S 
## Modifified by Markus Kraus (https://myclourevolution.com)
## Date : 19 Apr 2013
## Modified : 27 07 2017
## Version : 1.1
## 
##############################################################################

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## The URI list to test
$URLListFile = "C:\uptime\URLs.txt" 
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue

$Result = @()
 do {
  Foreach($Uri in $URLList) {
  $time = try{
  $request = $null
   ## Request the URI, and measure how long the response took.
  $result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri }
  $result1.TotalMilliseconds
  } 
  catch
  {
   <# If the request generated an exception (i.e.: 500 server
   error or 404 not found), we can pull the status code from the
   Exception.Response property #>
   $request = $_.Exception.Response
   $time = -1
  }  
  $result += [PSCustomObject] @{
  Time = Get-Date;
  Uri = $uri;
  StatusCode = [int] $request.StatusCode;
  StatusDescription = $request.StatusDescription;
  ResponseLength = $request.RawContentLength;
  TimeTaken =  $time; 
  }

}
$Result | Sort-Object time | Format-Table -AutoSize
$Result | Export-Csv C:\Uptime\result.csv -Delimiter ";"
Start-Sleep 10
}
until ($error.Count -gt 1000)