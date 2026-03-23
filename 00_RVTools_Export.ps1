<# Script To Pull VMs and Associated vCenter Server Names #>

clear

Write-Host "`n [*] Begin Of Execution [*] `n"


$Base = $PSScriptRoot.TrimEnd('\') + '\'
$RVToolsCommand = "ExportAll2xlsx"
$DisplayMessage = "RVTools"
$LoginAcctFile = $($Base + "vCenterLoginAccount.txt")
$RVToolsPath = "C:\Program Files (x86)\Dell\RVTools\RVTools.exe"
$Date = Get-Date -Format "yyyy-MM-dd"
$DirName = "RVToolsReport_$Date"
$Path = $($Base +"Outputs\RVTools_Reports\"+ $DirName)
$ZipPath = "$Path.zip"
if (Test-Path -Path $Path -PathType Container) {
    Remove-Item -Path $Path -Recurse -Force
}
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}
New-Item -ItemType directory -Path $Path -Force | out-null
$Collected = 0
$NRCount = 0
$NVCollected = 0
$MissCreds = 0
$NVFiles = ""
$NotResponding = ""
$NoAcc = 0
$NoAccessvCenters = ""

$CollectedRVTools = @("RVTools Extract of EntTech vCenters`n")
$CollectedRVTools += "These reports will be generated on 5th of every month`n`n"
$CollectedRVTools += "**Extracted $DisplayMessage(s) For**"

if ( $global:DefaultVIServers.Name.count -gt 0) {
	Disconnect-VIServer -Server * -Force -Confirm:$false
}

if (-not (Get-Module -ListAvailable CredentialManager)) {
    Install-Module CredentialManager -Scope CurrentUser -Force
}


[string[]]$vCentersList = Get-Content -Path $LoginAcctFile

foreach ($vCenterServer in $vCentersList) {
	
	$vCenter = $vCenterServer.split("\|")[0]
	$LoginCheck = $vCenterServer.split("\|")[1]
	if ( $LoginCheck -contains "PROD" ){
		$Creds = "Creds_Prod"
		} elseif ( $LoginCheck -contains "MGMT" ){
		$Creds = "Creds_Mgmt"
		} elseif ( $LoginCheck -contains "LAB" ){
		$Creds = "Creds_Lab"
		}else {
		$Creds = "No Login Access"
	}
	$CollectedData = ""
	try {
        $pingResult = Test-Connection -ComputerName $vCenter -Count 2 -ErrorAction Stop -Quiet
        if ($pingResult) {
			
			If ( $Creds -notmatch "No Login Access" ) {
				$Credentials = Get-StoredCredential -Target $Creds				
				
				if ([string]::IsNullOrWhiteSpace($Creds)) {
					
					Write-Host " [-] Credentials Missing For : $vCenter" -ForegroundColor DARKYellow
					
					$MissCreds++
					$MissCredsAddDot = ". "+ $vCenterServer
					$CollectedData = "$MissCreds$MissCredsAddDot"
					$MissCredentials += "$CollectedData`n"
					continue
				}
				
				$Credentials = Get-StoredCredential -Target $Creds -ErrorAction SilentlyContinue
				
				if (-not $Credentials -or
				[string]::IsNullOrWhiteSpace($Credentials.UserName) -or
				[string]::IsNullOrWhiteSpace($Credentials.GetNetworkCredential().Password)) {
					
					Write-Host " [-] Credentials Missing For : $vCenter" -ForegroundColor DARKYellow
					
					$MissCreds++
					$MissCredsAddDot = ". "+ $vCenter
					$CollectedData = "$MissCreds$MissCredsAddDot"
					$MissCredentials += "$CollectedData`n"
					continue					
				}
				
				$script:username = $Credentials.username
				$script:password = $Credentials.GetNetworkCredential().password
				
				$vCenterUser = $Credentials.username
				$vCenterPassword = $Credentials.GetNetworkCredential().password
				
				Connect-VIServer -Server $vCenter -user $Credentials.username -Password $vCenterPassword | out-null
				
				$ConnectedVCServers = @($global:DefaultVIServers.Name)
				
				. $($Base + "RVToolsPasswordEncryption.ps1") -InPass $vCenterPassword
				sleep 2
				
				if ( $ConnectedVCServers -contains $vCenter ) {
					
					$FileName = $($vCenter + ".xlsx")
					$Arguments = "-u $vCenterUser -p $RVToolsEncrytPassword -s $vCenter -c $RVToolsCommand -d $Path -f $FileName -DBColumnNames -ExcludeCustomAnnotations"
					$Process = Start-Process -FilePath $RVToolsPath -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
					<# Core #>
					
					$minSizeInBytes = 9000					
					if ( Test-Path -Path $($Path+"\"+$FileName) -PathType Leaf) {
						$fileInfo = Get-Item -Path $($Path+"\"+$FileName)
						$fileSize = $fileInfo.Length
						
						if ($fileSize -gt $minSizeInBytes) {
							$Collected++
							Write-Host " [+] $DisplayMessage [$Collected] : $vCenter"
							$AddDot = ". "+ $vCenter
							$CollectedData = "$Collected$AddDot"
							$CollectedRVTools += $CollectedData							
						}
						else {
							
							$NVCollected++
							$NVAddDot = ". "+ $vCenter
							$CollectedData = "$NVCollected$NVAddDot"
							$NVFiles += "$CollectedData`n"
						}
					}
					else {
						
						$NVCollected++
						$NVAddDot = ". "+ $vCenter
						$CollectedData = "$NVCollected$NVAddDot"
						$NVFiles += "$CollectedData`n"
						
					}
					Disconnect-VIServer -Server * -Force -Confirm:$false
				}
				} else {
				
				$NoAcc++
				$NoAddDot = ". "+ $vCenterServer
				$CollectedData = "$NoAcc$NoAddDot"
				$NoAccessvCenters += "$CollectedData`n"
			}
		}
        else {
			$NRCount++
			$WithDot = ". "+ $vCenter
			$CollectedData = "$NRCount$WithDot"
			$NotResponding += "$CollectedData`n"
		}
	}
    catch {
		continue
        
	}
}
Write-Host "`n [*] RVTools Extraction Is Completed"

if ([string]::IsNullOrEmpty($NVFiles)) {
	$NVFiles = "--`n"
}

if ([string]::IsNullOrEmpty($NotResponding)) {
	$NotResponding = "--"
}

if ([string]::IsNullOrEmpty($NoAccessvCenters)) {
	$NoAccessvCenters = "--"
}

$CollectedRVTools += "`n`n** vCenters Failed Authentication**`n$NoAccessvCenters"
$CollectedRVTools += "`n`n** Not A Valid Extracts**`n$NVFiles"
$CollectedRVTools += "`n** vCenters Not Responding**`n$NotResponding"
$CollectedRVTools += "`n** Missing credentials**`n$MissCredentials"
$CollectedRVTools += "`n `nThank you,"

########################### ZIP Collected Data ##########################
if (Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue) {
	Compress-Archive -Path "$Path\*" -DestinationPath $ZipPath -Force -ErrorAction SilentlyContinue
	Sleep 5
}

if (-not (Test-Path $ZipPath)) {
    Write-Host "`n [-] ZIP file was NOT created."
    $CollectedRVTools = "`n`n  ***   Unable To Attach The Extracts   ***"
	$CollectedRVTools += "`n`n Thank you,"

	
	} else {
	Write-Host "`n [*] Compressed the $DirName as $DirName.zip"
	$AttachmentPath = $ZipPath
	$attachment = New-Object System.Net.Mail.Attachment($AttachmentPath)
}


############################### Send Mail ###############################
$EmailFrom = "extractor.example.com"
$EmailTo = "requester.example.com"
$Subject = "$DirName"
$Body = "$DirName"

$SMTPServer = "smtpserver.example.com"
$SMTPPort = 25

$message = New-Object System.Net.Mail.MailMessage
$message.From = $EmailFrom
$message.To.Add($EmailTo)
$message.Subject = $Subject
$message.Body = $CollectedRVTools | Out-String

if (Test-Path $ZipPath) {
	$message.Attachments.Add($attachment)
}

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$smtp.EnableSsl = $true

try {
    $smtp.Send($message)
    Write-Host "`n [*] Email sent successfully"
	} catch {
    Write-Host "`n [-] Error sending email: $($_.Exception.Message)"
}

Write-Host "`n [*] End Of Execution  [*] `n"

<# End Of Script #>
