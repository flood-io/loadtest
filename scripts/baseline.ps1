$access_token = $env:MY_FLOOD_TOKEN
$target_url = $env:MY_TARGET_URL
$api_url = "https://api.flood.io"
$script_path = 'tests/jmeter/baseline.jmx'
$flood_project = 'Azure DevOps'
$flood_name = 'baseline'

# Setup the API URI that contains all parameters required to start a Grid, Flood and test settings.
$uri = "$api_url/api/floods?flood[tool]=jmeter&flood[threads]=150&flood[duration]=120&flood[project]=$flood_project&flood[privacy]=public&flood[name]=$flood_name&flood[override_parameters]=-Jtarget_url=$target_url&flood[grids][][infrastructure]=demand&flood[grids][][instance_quantity]=1&flood[grids][][region]=us-east-1&flood[grids][][instance_type]=m5.xlarge&flood[grids][][stop_after]=10"

# Encode the Flood auth token with Base64 and use it as a header for our request to Flood API
$bytes = [System.Text.Encoding]::ASCII.GetBytes($access_token)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{
    'Authorization' = $basicAuthValue
}

# Read the script file and transplant it as part of a UTF-8 based payload
$fileBytes = [System.IO.File]::ReadAllBytes($script_path);
$fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes);
$boundary = [System.Guid]::NewGuid().ToString();
$LF = "`r`n";
$contentType = "multipart/form-data; boundary=`"$boundary`""
$payload = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"flood_files[]`"; filename=`"jmeter_1000rpm.jmx`"",
    "Content-Type: application/octet-stream$LF",
    $fileEnc,
    "--$boundary--$LF"
) -join $LF

# Submit the POST request to the Flood API and capture the returned Flood UUID
# Store the Flood UUID as a variable that can be shared with other Azure Devops steps
try {
    $responseFull = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -ContentType $contentType -Body $payload

    $outFloodID = $responseFull.uuid
    Write-Output "Flood ID is: $outFloodID"
    Write-Output "##vso[task.setvariable variable=flood_uuid;]$outFloodID"
    Write-Output "##vso[task.setvariable variable=GITHUB_COMMENT;]Your flood results are at: https://app.flood.io/$outFloodID"
}
catch {
    $responseBody = ""
    $errorMessage = $_.Exception.Message
    if (Get-Member -InputObject $_.Exception -Name 'Response') {
        write-output $_.Exception.Response

        try {
            $result = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($result, [System.Text.Encoding]::ASCII)
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $responseBody = $reader.ReadToEnd();
            Write-Output "response body: $responseBody"
        }
        catch {
            Throw "An error occurred while calling REST method at: $uri. Error: $errorMessage. Cannot get more information."
        }
    }
    Throw "An error occurred while calling REST method at: $uri. Error: $errorMessage. Response body: $responseBody"
}
