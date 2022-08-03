[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#OU where you want to pull employee emails from
$usersOU = "OU=Employees,DC=AD,DC=DOMAIN,DC=COM"
#Your API Key, https://support.atlassian.com/statuspage/docs/create-and-manage-api-keys/
$APIKey = ""
#Your OrgID can be found after pages in your url: https://manage.statuspage.io/pages/
$OrgID = ""
#Grabbing the emails of all accounts, you may need to use a different attribute if you don't store yours in mail
$ListOfEmails = Get-ADUser -Filter "*" -SearchBase "$usersOU" -Properties mail | Select-Object -ExpandProperty mail
ForEach($email in $ListOfEmails){Write-host "Adding: $email"
$Header = @{Authorization = "OAuth $APIKey"}
#You could pass first name and last name as well if needed
#skip_confirmation_notification is set to true so that users don't have to validate their email
$hash = [ordered]@{
    subscriber = [ordered]@{
        email="$email";
        skip_confirmation_notification=$true;

    }
}
$json = $hash | ConvertTo-Json -Depth 99
try{
#Hit the API and pass our paramters to create the subscriber	
Invoke-RestMethod -Uri https://api.statuspage.io/v1/pages/$OrgID/subscribers -Method Post -ContentType 'application/json' -Body $Json -Headers $Header
}
catch{
	#Catch any errors and display them
	Write-Host "Investigate anything that shows up here:" -ForegroundColor red
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
	Write-host "End of Error"}
	#Making the script sleep for 1 second to ensure we don't go over the API limit, you can have your limit increased above one a second but by default you can only initiate 1 request a second
    start-sleep -Seconds 1 
}

