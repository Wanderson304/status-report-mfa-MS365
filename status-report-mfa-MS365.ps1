#Creídto do script: JamesTran
#https://learn.microsoft.com/en-us/answers/questions/1343593/users-with-mfa-enabled-disabled-enforced

#Instalação do modulo MSOnline
Install-Module MSOnline

#Autenticação na conta
Connect-MsolService

cls

Write-Host "========================================================================================== "
Write-Host "                      Relatório de status de MFA - Microsoft 365"
Write-Host "                      Criado por: JamesTran"
Write-Host "                      Personalizado por: Wanderson Silva"
Write-Host "========================================================================================== "

Write-Host " "
Write-Host " "

Write-Host "Um momento. Gerando o relatório de status de MFA"
Write-Host "o ARQUIVO FICARÁ DISPONIVEL no diretório c:\Temp-report-mfa\"

Write-Host " "
Write-Host " "

Write-Host "========================================================================================== "
Write-Host "                       Relatório de status de MFA - Microsoft 365"
Write-Host "========================================================================================== "

Start-Sleep -Seconds 30


cls

Write-Host "Finding Azure Active Directory Accounts..."
$Users = Get-MsolUser -All | Where-Object { $_.UserType -ne "Guest" }
$Report = [System.Collections.Generic.List[Object]]::new() # Create output file
Write-Host "Processing" $Users.Count "accounts..." 
ForEach ($User in $Users) {

    $MFADefaultMethod = ($User.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType
    $MFAPhoneNumber = $User.StrongAuthenticationUserDetails.PhoneNumber
    $PrimarySMTP = $User.ProxyAddresses | Where-Object { $_ -clike "SMTP*" } | ForEach-Object { $_ -replace "SMTP:", "" }
    $Aliases = $User.ProxyAddresses | Where-Object { $_ -clike "smtp*" } | ForEach-Object { $_ -replace "smtp:", "" }

    If ($User.StrongAuthenticationRequirements) {
        $MFAState = $User.StrongAuthenticationRequirements.State
    }
    Else {
        $MFAState = 'Disabled'
    }

    If ($MFADefaultMethod) {
        Switch ($MFADefaultMethod) {
            "OneWaySMS" { $MFADefaultMethod = "Text code authentication phone" }
            "TwoWayVoiceMobile" { $MFADefaultMethod = "Call authentication phone" }
            "TwoWayVoiceOffice" { $MFADefaultMethod = "Call office phone" }
            "PhoneAppOTP" { $MFADefaultMethod = "Authenticator app or hardware token" }
            "PhoneAppNotification" { $MFADefaultMethod = "Microsoft authenticator app" }
        }
    }
    Else {
        $MFADefaultMethod = "Not enabled"
    }
  
    $ReportLine = [PSCustomObject] @{
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        MFAState          = $MFAState
        MFADefaultMethod  = $MFADefaultMethod
        MFAPhoneNumber    = $MFAPhoneNumber
        #PrimarySMTP       = ($PrimarySMTP -join ',')
        #Aliases           = ($Aliases -join ',')
    }
                 
    $Report.Add($ReportLine)
}

#Apagar pasta Temp-report-mfa existente
Remove-Item C:\Temp-report-mfa -Force -Recurse

#Criar pasta Temp-report-mfa
New-Item -Name "Temp-report-mfa" -Path "C:\" -ItemType Directory


Write-Host "Report is in c:\Temp-report-mfa\MFAUsers-Status.csv"
$Report | Sort-Object UserPrincipalName | Export-CSV -Encoding UTF8 -NoTypeInformation "c:\Temp-report-mfa\MFAUsers-Status.csv"

cls

Write-Host "========================================================================================== "
Write-Host "                      Relatório de status de MFA - Microsoft 365"
Write-Host "                      Criado por: JamesTran"
Write-Host "                      Personalizado por: Wanderson Silva"
Write-Host "========================================================================================== "

Write-Host " "
Write-Host " "

Write-Host "Tudo pronto. Seu relatório de MFA foi gerado o nome do arquivo é MFAUsers-Status.csv"
Write-Host "ele estar localizado no diretório c:\Temp-report-mfa\"

Write-Host " "

Write-Host "Porém se você esperar 10 segundinhos eu vou gerar aqui pra você uma tela de vizulização estantania"

Write-Host " "

Write-Host "Prontinhos ...."

Write-Host " "
Write-Host " "

$Report | Select-Object UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber | Sort-Object UserPrincipalName | Out-GridView

Write-Host "Essa tela será fechada em 2 Minutos ...."

Write-Host " "
Write-Host " "

Write-Host "========================================================================================== "
Write-Host "                       Relatório de status de MFA - Microsoft 365"
Write-Host "========================================================================================== "

Start-Sleep -Seconds 120

cls
