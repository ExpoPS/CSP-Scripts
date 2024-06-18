<#
.SYNOPSIS
    Creates GDAP Admin Relationships

.DESCRIPTION

.NOTES
Stuart Fordham
Change Log
V1.0, 02/11/2023 Initial Version
V
NEEDS - 

#>

$script:logpath = "C:\Temp\GDAP"
$script:year = "2024"
$script:version = "1.1"


#Check Temp Folder Exists
if(!(Test-Path -Path $logpath)){
    New-Item -ItemType directory -Path $logpath 
	Write-Host "Folder path $($logpath) created"}

[BOOLEAN]$global:xExitSession=$false

function ConnectModules(){
    #Check that PowerShell modules are loaded
    
    #Connect to MgGraph
    try {$Module = Get-MgContext -ErrorAction SilentlyContinue}
    catch {}
    If (!$Module){
    $Mod = Get-Module -ListAvailable -Name "Microsoft.Graph.Beta.Identity.Partner"
    Write-Host "`nNot connected to Microsoft.Graph.Beta.Identity.Partner, Connecting..." -ForegroundColor Yellow
    If (!$Mod)
    {
        Write-Host "`nMicrosoft.Graph.Beta.Identity.Partner Module is not present, attempting to install it"
        
        Install-Module -Name Microsoft.Graph.Beta.Identity.Partner, Microsoft.Graph.Groups, Microsoft.Graph.Authentication -Scope CurrentUser
        Import-Module "$home\Documents\WindowsPowerShell\Modules\Microsoft.Graph.Beta.Identity.Partner","$home\Documents\WindowsPowerShell\Modules\Microsoft.Graph.Beta.Groups","$home\Documents\WindowsPowerShell\Modules\Microsoft.Graph.Authentication" -ErrorAction SilentlyContinue

        Connect-MgGraph -Scopes "DelegatedAdminRelationship.ReadWrite.All,GroupMember.Read.All" -Verbose
    }else {
        Connect-MgGraph -Scopes "DelegatedAdminRelationship.ReadWrite.All,GroupMember.Read.All" -Verbose
            }
        }ElseIf($Module){
    Write-Host "`nMicrosoft.Graph.Beta.Identity.Partner is already connected for $($Module.Account)" -ForegroundColor Green}    
    
    #Connect to PartnerCenter
    try {$Module2 = Get-PartnerOrganizationProfile -ErrorAction SilentlyContinue}
    catch {}
    If (!$Module2){
    $Mod = Get-Module -ListAvailable -Name "PartnerCenter"
    Write-Host "`nNot connected to PartnerCenter, Connecting..." -ForegroundColor Yellow
    If (!$Mod)
    {
        Write-Host "`nPartnerCenter Module is not present, attempting to install it"
        
        Install-Module -Name PartnerCenter -Scope CurrentUser
        Import-Module "$home\Documents\WindowsPowerShell\Modules\PartnerCenter" -ErrorAction SilentlyContinue
        Connect-PartnerCenter
    }else {
        Connect-PartnerCenter
            }
        }ElseIf($Module2){
    Write-Host "`nPartnerCenter is already connected for $($Module2.CompanyName)" -ForegroundColor Green}    


    $script:customertable = Get-PartnerCustomer
    
    Start-Sleep -Seconds 3
}
function LoadMainMenuSystem(){
    do{
	[INT]$xMenu1 = 0
	while ( $xMenu1 -lt 1 -or $xMenu1 -gt 13 ){
		Clear-Host
		#… Present the Menu Options
        Write-Host "`n"
        Write-Host "`t***********************************************" -ForegroundColor DarkGreen
		Write-Host "`t*     Exponential-e CSP GDAP Script - v1.1    *" -ForegroundColor DarkGreen
        Write-Host "`t***********************************************" -ForegroundColor DarkGreen
		Write-Host "`t*" -Fore DarkGreen -NoNewline;Write-Host "    Ensure you connect to PowerShell first   " -ForegroundColor Red -NoNewline;Write-Host "*" -Fore DarkGreen
        Write-Host "`t***********************************************" -ForegroundColor DarkGreen
        Write-Host ""
        Write-Host "`t`t1. Connect to PowerShell Modules" -Fore Green
        Write-Host "`t`t2. Select Customer" -Fore Yellow
        Write-Host ""
        Write-Host "`t-----------------------------------------------" -ForegroundColor DarkGreen
        Write-Host ""
        Write-Host "`tCreate GDAP Admin Relationship`n" -Fore DarkYellow
        Write-Host "`t`t3. Create - M365 Managed Customer" -Fore White
        Write-Host "`t`t4. Create - Support Request Only" -Fore White
        Write-Host "`t`t5. Create - TCaaS Only" -Fore White
        Write-Host ""
        Write-Host "`t-----------------------------------------------" -ForegroundColor DarkGreen
        Write-Host ""
        Write-Host "`tAssign GDAP Admin Relationship`n" -Fore DarkYellow
        Write-Host "`t`t6. Assign - M365 Managed Customer" -Fore White
        Write-Host "`t`t7. Assign - Support Request Only" -Fore White
        Write-Host "`t`t8. Assign - TCaaS Only" -Fore White
        Write-Host ""       
        Write-Host "`t-----------------------------------------------" -ForegroundColor DarkGreen
        Write-Host ""
        Write-Host "`tCSOC - Create/Assign GDAP Admin Relationship`n" -Fore DarkYellow
        Write-Host "`t`t9. Create - CSOC GDAP" -Fore White
        Write-Host "`t`t10. Assign - CSOC GDAP" -Fore White
        Write-Host ""       
        Write-Host "`t-----------------------------------------------" -ForegroundColor DarkGreen
        Write-Host ""           
        Write-Host "`t`t11. Check Admin Relationship Status" -Fore DarkBlue
        Write-Host "`t`t12. Show Log" -Fore Blue
        Write-Host "`t`t13. Quit`n" -Fore DarkRed
        
        #… Retrieve the response from the user
        [int]$xMenu1 = Read-Host "`t`tEnter Menu Option Number"}
        
    Switch ($xMenu1){    #… User has selected a valid entry.. load next menu
        1 {Write-Host "`n`tConnect to PowerShell Modules" -ForegroundColor Yellow
        Start-Sleep -s 1
        ConnectModules
        }
        2 {Write-Host "`n`tSelect Customer" -ForegroundColor Yellow
        Start-Sleep -s 3
        CustomerSelection
        }
        3 {Write-Host "`n`tCreate - M365 Managed Customer" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        CreateGDAPM365Managed
        CreateReadOnly
        Write-Host "`nCreating Admin Relationship Complete" -ForegroundColor Green
        AnyKey
        }
        4 {Write-Host "`n`tCreate - Support Request Only" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        CreateGDAPSROnly
        CreateReadOnly
        Write-Host "`nCreating Admin Relationship Complete" -ForegroundColor Green
        AnyKey
        }
        5 {Write-Host "`n`tCreate - TCaaS Only" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        CreateGDAPTCaaS
        CreateReadOnly
        Write-Host "`nCreating Admin Relationship Complete" -ForegroundColor Green
        AnyKey
        }
        6 {Write-Host "`n`tAssign - M365 Managed Customer" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        AssignGDAPM365Managed
        AssignReadOnly
        Write-Host "`nAssigning Admin Relationships Complete" -ForegroundColor Green
        AnyKey
        }
        7 {Write-Host "`n`tAssign - Support Request Only" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        AssignGDAPSROnly
        AssignReadOnly
        Write-Host "`nAssigning Admin Relationships Complete" -ForegroundColor Green
        AnyKey
        }
        8 {Write-Host "`n`tAssign - TCaaS Only" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        AssignGDAPTCaaS
        AssignReadOnly
        Write-Host "`nAssigning Admin Relationships Complete" -ForegroundColor Green
        AnyKey
        }
        9 {Write-Host "`n`tCreate - CSOC GDAP" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        CreateGDAPCSOC
        Write-Host "`nAssigning Admin Relationships Complete" -ForegroundColor Green
        AnyKey
        }
        10 {Write-Host "`n`tAssign - CSOC GDAP" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 3
        AssignGDAPCSOC
        Write-Host "`nAssigning Admin Relationships Complete" -ForegroundColor Green
        AnyKey
        }
        11 {Write-Host "`n`tCheck Admin Relationship Status" -ForegroundColor Yellow
        CheckforCustomer
        Start-Sleep -s 1
        ARStatus
        }
        12 {Write-Host "`n`tYou selected Show Log - '$($logpath)\LogFile.csv'`n" -ForegroundColor Yellow
        Start-Sleep -s 3
        ShowLog}
        13 {Exit}
	}
} while ( $userMenuChoice -ne 11 )
}

function CustomerSelection(){   
    if($customer){
        Add-Type -AssemblyName PresentationFramework
        $msgBody = "Customer '$($customer.Name)' already selected, would you like to change?"
        $msgTitle = "Admin Relationship"
        $msgButton = 'YesNo'
        $msgImage = 'Question'
        $msgboxInput=[System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
        switch ($msgboxInput) {    
            'Yes' {    
             Write-Host "`nSelect the customer from the pop-up table"
             Start-Sleep -Seconds 1
             
             $script:customer = $customertable | Select-Object Name,Domain,CustomerId | Sort-Object Name | Out-GridView -Title "Select Customer" -PassThru
             Write-Host "`n$($customer.Name) Selected" -ForegroundColor Green
             AnyKey
            }
            'No' {
           Continue
            }
        }
    }else{
        Write-Host "`nSelect the customer from the table"
        Start-Sleep -Seconds 2
        
        $script:customer = $customertable | Select-Object Name,Domain,CustomerId | Sort-Object Name | Out-GridView -Title "Select Customer" -PassThru
        Write-Host "`n$($customer.Name) Selected" -ForegroundColor Green
        AnyKey
    }
}

function CheckforCustomer(){   
    if(!$customer){
        Write-Host "`n** No customer selected - Choose customer first **" -Fore Red
        Start-Sleep -Seconds 2
        LoadMainMenuSystem
    }
}

function ARStatus(){
    $relationships = ""
try {
    $relationships = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "Customer/TenantId eq '$($customer.CustomerId)'"   
}
catch {
    Write-Host "`nThe Customer '$($customer.Name)' has no Admin Relationships" -ForegroundColor Red
}

    if(!$relationships){
    }else{
    ForEach ($relationship in $relationships){
        Write-Host "`nThe Admin Relationship '$($relationship.DisplayName)' Status is " -NoNewline;if($relationship.Status -eq "active"){Write-Host "'$($relationship.Status)'" -ForegroundColor Green -NoNewline}if($relationship.Status -match  "created|approvalpending"){Write-Host "'$($relationship.Status)'" -ForegroundColor Yellow -NoNewline}if($relationship.Status -match "expired|terminated"){Write-Host "'$($relationship.Status)'" -ForegroundColor Red -NoNewline}

         #<and is expiring '$($relationship.EndDateTime)'" -ForegroundColor Blue>
    }
}
    AnyKey
    }

function CreateGDAPSROnly(){
   
    #SROnly
    ## Service Support Administrator
    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating SR Only Admin Relationship" -PercentComplete 50
    
    $name = "GDAP_$($year)_SROnly_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

    try {
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"  
    }
    catch {}
        if ($rel){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{

        $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }
    
    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }

    function CreateReadOnly(){
   #ReadOnly
    ## Billing Administrator
    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating Read Only Admin Relationship" -PercentComplete 50
    
    $name = "GDAP_$($year)_ReadOnly_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "b0f54661-2d74-4c50-afa3-1ec803f12efe"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }
function CreateGDAPTCaaS(){

    #TCaaS
    ## License administrator
    ## Service support administrator
    ## Teams Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating TCaaS Admin Relationship" -PercentComplete 0
    
    $name = "GDAP_$($year)_TCaaS_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
 
    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{   
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
        }
    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    
    
    <#UC TCaaS
        ## Service Support Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating UC TCaaS Admin Relationship" -PercentComplete 50
    
    $name = "GDAP_$($year)_UCTeam_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    
    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }
#>

    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }

    function CreateGDAPCSOC(){

        #CSOC
        ## Security Reader
    
        Write-Progress -Activity "Creating Admin Relationship" -Status "Creating CSOC Admin Relationship" -PercentComplete 0
        
        $name = "GDAP_$($year)_CSOC_$($customer.Name.replace(' ',''))"
        $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
     
        if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
            Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
            Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
            }else{   
        $params = @{
            displayName = "$($AdminRelationshipName)"
            duration = "P730D"
            autoExtendDuration = "P180D"
            customer = @{
                tenantId = "$($customer.CustomerId)"
                displayName = "$($customer.Name)"
            }
            accessDetails = @{
                unifiedRoles = @(
                    @{
                        roleDefinitionId = "5d6b6bb7-de71-4623-b4af-96380a352509"
                    }

                )
            }
        }
        New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null
    
        $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
        $params = @{
            action = "lockForApproval"
        }
        New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
            }
        Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
        Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    
        Write-Progress -Activity "Creating Admin Relationship" -Completed
        }

function CreateGDAPM365Managed(){
    #End User Support
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator
    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating End User Admin Relationship" -PercentComplete 15
    
    $name = "GDAP_$($year)_EndUser_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    
    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }
    #1st Line
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating 1st Line Admin Relationship" -PercentComplete 30
    
    $name = "GDAP_$($year)_1stLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    #2nd Line
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating 2nd Line Admin Relationship" -PercentComplete 45
    
    $name = "GDAP_$($year)_2ndLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

    if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    #3rd Line
        ##Application Administrator
        ##Compliance Administrator
        ##Conditional Access Administrator
        ##Exchange Administrator
        ##Groups Administrator
        ##Intune Administrator
        ##License Administrator
        ##Security Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating 3rd Line Admin Relationship" -PercentComplete 60
    
    $name = "GDAP_$($year)_3rdLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

        if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
                }
                @{
                    roleDefinitionId = "17315797-102d-40b4-93e0-432062caca18"
                }
                @{
                    roleDefinitionId = "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9"
                }
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "fdd7a751-b60b-444a-984c-02652fe8fa1c"
                }
                @{
                    roleDefinitionId = "3a2c62db-5318-420d-8d74-23affee5d9d5"
                }
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "194ae4cb-b126-40b2-bd5b-6091b380977d"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    #Professional Services
        ##Application Administrator
        ##Compliance Administrator
        ##Conditional Access Administrator
        ##Exchange Administrator
        ##Groups Administrator
        ##Intune Administrator
        ##License Administrator
        ##Security Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating Professional Service Admin Relationship" -PercentComplete 75
    
    $name = "GDAP_$($year)_PS_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

        if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        autoExtendDuration = "P180D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
           unifiedRoles = @(
                @{
                    roleDefinitionId = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
                }
                @{
                    roleDefinitionId = "17315797-102d-40b4-93e0-432062caca18"
                }
                @{
                    roleDefinitionId = "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9"
                }
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "fdd7a751-b60b-444a-984c-02652fe8fa1c"
                }
                @{
                    roleDefinitionId = "3a2c62db-5318-420d-8d74-23affee5d9d5"
                }
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "194ae4cb-b126-40b2-bd5b-6091b380977d"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    #Global Admin
        ##Global Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating Global Admin Admin Relationship" -PercentComplete 90
    
    $name = "GDAP_$($year)_GA_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))

        if (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' already exists, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' Already Exists" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
    $params = @{
        displayName = "$($AdminRelationshipName)"
        duration = "P730D"
        customer = @{
            tenantId = "$($customer.CustomerId)"
            displayName = "$($customer.Name)"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "62e90394-69f5-4237-9190-012177145e10"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationship -BodyParameter $params | Out-Null

    $delegatedAdminRelationshipId = (Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'").Id
    $params = @{
        action = "lockForApproval"
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipRequest -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nCreated Admin Relationship - $($AdminRelationshipName), please copy the following link and send to customer for approval -" -NoNewline; Write-Host "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)" -ForegroundColor Yellow
    Write-Log -Message "Created Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }
        
    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }
     
function AssignGDAPSROnly(){
   
        #SROnly
        ## Service Support Administrator
        Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning SR Only Admin Relationship" -PercentComplete 50
        
        $name = "GDAP_$($year)_SROnly_$($customer.Name.replace(' ',''))"
        $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
        $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
        $delegatedAdminRelationshipId = $rel.id
        $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

        if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{

        $params = @{
            accessContainer = @{
                accessContainerId = "e192cd14-b389-4bc0-a842-589322a8dd81"
                accessContainerType = "securityGroup"
            }
            accessDetails = @{
                unifiedRoles = @(
                    @{
                        roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                    }
                )
            }
        }
        
        New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
    
        Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
        Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

        Write-Progress -Activity "Creating Admin Relationship" -Completed
    }

function AssignReadOnly(){
 #ReadOnly
        ## Billing Administrator
        Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning Read Only Admin Relationship" -PercentComplete 50
        
        $name = "GDAP_$($year)_ReadOnly_$($customer.Name.replace(' ',''))"
        $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
        $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
        $delegatedAdminRelationshipId = $rel.id
        $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

        if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
        $params = @{
            accessContainer = @{
                accessContainerId = "5c6e18f4-f07f-4a1b-b718-9d28b368acd6"
                accessContainerType = "securityGroup"
            }
            accessDetails = @{
                unifiedRoles = @(
                    @{
                        roleDefinitionId = "b0f54661-2d74-4c50-afa3-1ec803f12efe"
                    }
                )
            }
        }
        
        New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
            
        Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
        Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

        Write-Progress -Activity "Creating Admin Relationship" -Completed
    }
function AssignGDAPTCaaS(){

    #TCaaS
    ## License administrator
    ## Service support administrator
    ## Teams Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning TCaaS Admin Relationship" -PercentComplete 50
    
    $name = "GDAP_$($year)_TCaaS_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
    Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
    Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "14357ba0-4971-47e0-b5f2-9e15bf615f50"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
}
    <#
    #UC TCaaS
        ## Service Support Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating UC TCaaS Admin Relationship" -PercentComplete 50
    
    $name = "GDAP_$($year)_UCTeam_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
    Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
    Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{    
    $params = @{
        accessContainer = @{
            accessContainerId = "796416c9-4203-4c1e-9785-a4589dff3695"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
            )
        }
    }
    
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
    
    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }
    #>
    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }

    function AssignGDAPCSOC(){

        #CSOC
        ## License administrator
        ## Service support administrator
        ## Teams Administrator
    
        Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning CSOC Admin Relationship" -PercentComplete 50
        
        $name = "GDAP_$($year)_CSOC_$($customer.Name.replace(' ',''))"
        $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
        $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
        $delegatedAdminRelationshipId = $rel.id
        $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)
    
        if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
        }else{
        $params = @{
            accessContainer = @{
                accessContainerId = "1d62d2b7-103d-4d52-9eee-9105b8948e94"
                accessContainerType = "securityGroup"
            }
            accessDetails = @{
                unifiedRoles = @(
                    @{
                        roleDefinitionId = "5d6b6bb7-de71-4623-b4af-96380a352509"
                    }
                )
            }
        }
        New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null
    
        Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
        Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }
        Write-Progress -Activity "Creating Admin Relationship" -Completed
        }

function AssignGDAPM365Managed(){

    #Check GA Group is created first
    Add-Type -AssemblyName PresentationFramework
    $msgBody = "Is the customers Global Admin PAG Group Created?"
    $msgTitle = "Admin Relationship"
    $msgButton = 'YesNo'
    $msgImage = 'Question'
    $msgboxInput=[System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)
    switch ($msgboxInput) {    
        'Yes' {  
    $CustomerCode = TextBox "Enter Customer Code i.e CUS123"  

    $Group = (Get-MgBetaGroup -Filter "DisplayName eq 'PAG-GDAP-$($CustomerCode)-GlobalAdmin'")
    if ($Group) {
        $GAGroupID = $Group.ID
    } else {
        Write-Host "`nPAG Global Admin Group not found ensure the Global Admin Group is created first, then try again" -ForegroundColor Red
        Write-Log -Message "PAG GLobal Admin Group 'PAG-GDAP-$($CustomerCode)-GlobalAdmin' not found" -Severity "Error" -Process "$($customer.Name)" -Object "PAG-GDAP-$($CustomerCode)-GlobalAdmin"
        Start-Sleep -Seconds 3
        LoadMainMenuSystem
    }
        }
        'No' {
        Write-Host "`nEnsure the Global Admin Group is created first, then try again" -ForegroundColor Yellow
        Start-Sleep -s 3
        LoadMainMenuSystem
        }
    }

    #End User Support
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning End User Admin Relationship" -PercentComplete 15
    
    $name = "GDAP_$($year)_EndUser_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{    
    $params = @{
        accessContainer = @{
            accessContainerId = "b41a925f-8f90-4212-ba61-f443f31f6202"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
        }

    #1st Line
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning 1st Line Admin Relationship" -PercentComplete 30
    
    $name = "GDAP_$($year)_1stLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "b6083a59-77a9-41dd-b034-5022255ead91"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }

    #2nd Line
        ##Exchange Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator
        ##Helpdesk Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning 2nd Line Admin Relationship" -PercentComplete 45
    
    $name = "GDAP_$($year)_2ndLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "6a6fc8c6-9d71-4d8d-a017-fdd419a69d90"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
                @{
                    roleDefinitionId = "729827e3-9c14-49f7-bb1b-9608f156bbb8"
                }
            )
        }
    }
    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }

    #3rd Line
        ##Application Administrator
        ##Compliance Administrator
        ##Conditional Access Administrator
        ##Exchange Administrator
        ##Groups Administrator
        ##Intune Administrator
        ##License Administrator
        ##Security Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning 3rd Line Admin Relationship" -PercentComplete 60
    
    $name = "GDAP_$($year)_3rdLine_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "2cd817ee-2b51-42ac-8485-ecd7676ddda7"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
                }
                @{
                    roleDefinitionId = "17315797-102d-40b4-93e0-432062caca18"
                }
                @{
                    roleDefinitionId = "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9"
                }
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "fdd7a751-b60b-444a-984c-02652fe8fa1c"
                }
                @{
                    roleDefinitionId = "3a2c62db-5318-420d-8d74-23affee5d9d5"
                }
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "194ae4cb-b126-40b2-bd5b-6091b380977d"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
            )
        }
    }

    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }

    #Professional Services
        ##Application Administrator
        ##Compliance Administrator
        ##Conditional Access Administrator
        ##Exchange Administrator
        ##Groups Administrator
        ##Intune Administrator
        ##License Administrator
        ##Security Administrator
        ##Service Support Administrator
        ##SharePoint Administrator
        ##Teams Administrator
        ##User Administrator
        ##Authentication Administrator

    Write-Progress -Activity "Creating Admin Relationship" -Status "Creating Professional Service Admin Relationship" -PercentComplete 75
    
    $name = "GDAP_$($year)_PS_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "cd3f998c-89f6-4299-8ee9-8f245d08b9b7"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
                }
                @{
                    roleDefinitionId = "17315797-102d-40b4-93e0-432062caca18"
                }
                @{
                    roleDefinitionId = "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9"
                }
                @{
                    roleDefinitionId = "29232cdf-9323-42fd-ade2-1d097af3e4de"
                }
                @{
                    roleDefinitionId = "fdd7a751-b60b-444a-984c-02652fe8fa1c"
                }
                @{
                    roleDefinitionId = "3a2c62db-5318-420d-8d74-23affee5d9d5"
                }
                @{
                    roleDefinitionId = "4d6ac14f-3453-41d0-bef9-a3e0c569773a"
                }
                @{
                    roleDefinitionId = "194ae4cb-b126-40b2-bd5b-6091b380977d"
                }
                @{
                    roleDefinitionId = "f023fd81-a637-4b56-95fd-791ac0226033"
                }
                @{
                    roleDefinitionId = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
                }
                @{
                    roleDefinitionId = "69091246-20e8-4a56-aa4d-066075b2a7a8"
                }
                @{
                    roleDefinitionId = "fe930be7-5e62-47db-91af-98c3a49a38b1"
                }
                @{
                    roleDefinitionId = "c4e39bd9-1100-46d3-8c65-fb160da0071f"
                }
            )
        }
    }

    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }

    #Global Admin
        ##Global Administrator

    Write-Progress -Activity "Assigning Admin Relationship" -Status "Assigning Global Admin Admin Relationship" -PercentComplete 90
    
    $name = "GDAP_$($year)_GA_$($customer.Name.replace(' ',''))"
    $AdminRelationshipName = $name.subString(0, [System.Math]::Min(50, $name.Length))
    $rel = Get-MgBetaTenantRelationshipDelegatedAdminRelationship -Filter "DisplayName eq '$($AdminRelationshipName)'"
    $delegatedAdminRelationshipId = $rel.id
    $relassignment = Get-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $($delegatedAdminRelationshipId)

    if ($relassignment){
        Write-Host "`nAdmin Relationship '$($AdminRelationshipName)' is already assigned roles, Skipping" -ForegroundColor Yellow
        Write-Log -Message "Admin Relationship '$($AdminRelationshipName)' is already assigned roles" -Severity "Warning" -Process "$($customer.Name)" -Object "$($AdminRelationshipName)"
    }else{
    $params = @{
        accessContainer = @{
            accessContainerId = "$($GAGroupID)"
            accessContainerType = "securityGroup"
        }
        accessDetails = @{
            unifiedRoles = @(
                @{
                    roleDefinitionId = "62e90394-69f5-4237-9190-012177145e10"
                }
            )
        }
    }

    New-MgBetaTenantRelationshipDelegatedAdminRelationshipAccessAssignment -DelegatedAdminRelationshipId $delegatedAdminRelationshipId -BodyParameter $params | Out-Null

    Write-Host "`nAssigned Permissions to Admin Relationship - $($AdminRelationshipName)" -ForegroundColor White
    Write-Log -Message "Assigned Permissions to Admin Relationship - $($AdminRelationshipName)" -Severity "Information" -Process "$($customer.Name)" -Object "https://admin.microsoft.com/AdminPortal/Home#/partners/invitation/granularAdminRelationships/$($delegatedAdminRelationshipId)"
    }

    Write-Progress -Activity "Creating Admin Relationship" -Completed
    }
             

Function AnyKey{
    Write-Host '
    Press any key to continue...' -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    }
function BlankFunction(){
       #Error
       $ErrorMsg = "The folder path '$($script:cqvmpath)' does not contain any files"
        Add-Type -AssemblyName PresentationFramework
        $msgboxInput=[System.Windows.MessageBox]::Show($ErrorMsg,"Error",'OK','Error')
        switch ($msgboxInput) {
            'OK' {Write-Host "`n$($ErrorMsg)" -ForegroundColor Red
            Start-Sleep -Seconds 5}}
                Break
        #Error End        
        }

        function TextBox($text){
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'Enter the appropriate information'
            $form.Size = New-Object System.Drawing.Size(360,150)
            $form.StartPosition = 'CenterScreen'
            $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
            $form.Topmost = $true
        
            ### Adding an OK button to the text box window
            $OKButton = New-Object System.Windows.Forms.Button
            $OKButton.Location = New-Object System.Drawing.Point(105,75)
            $OKButton.Size = New-Object System.Drawing.Size(75,23)
            $OKButton.Text = 'OK'
            $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton = $OKButton
            $form.Controls.Add($OKButton)
        
            ### Adding a Cancel button to the text box window
            $CancelButton = New-Object System.Windows.Forms.Button
            $CancelButton.Location = New-Object System.Drawing.Point(190,75)
            $CancelButton.Size = New-Object System.Drawing.Size(75,23)
            $CancelButton.Text = 'Cancel'
            $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton = $CancelButton
            $form.Controls.Add($CancelButton)
        
            ### Putting a label above the text box
            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10,10)
            $label.AutoSize = $True
            $Font = New-Object System.Drawing.Font("Arial",10)
            $label.Font = $Font
            $label.Text = $text
            $form.Controls.Add($label)
        
            ### Inserting the text box that will accept input
            $textBox = New-Object System.Windows.Forms.TextBox
            $textBox.Location = New-Object System.Drawing.Point(10,40)
            $textBox.Size = New-Object System.Drawing.Size(325,25)
            $textBox.Multiline = $false
            $textbox.AcceptsReturn = $false
            $form.Controls.Add($textBox)
        
            $form.Add_Shown({$textBox.Select()}) ### Activates the form and sets the focus on it
            $result = $form.ShowDialog() 
            
            if ($result -eq [System.Windows.Forms.DialogResult]::OK){
               $textBox.Text
            }
        }

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Object,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Process,
 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
 
    [pscustomobject]@{
        Time = (Get-Date -f s)
        Severity = $Severity
        Message = $Message
        Object = $Object
        Process = $Process
    } | Export-Csv -Path "$($logpath)\LogFile.csv" -Append -NoTypeInformation -Force
 }

 function ShowLog {
 Import-Csv -Path "$($logpath)\LogFile.csv" | Out-GridView
 AnyKey
 }

LoadMainMenuSystem