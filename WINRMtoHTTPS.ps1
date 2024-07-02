# Variables
$dnsName = "exemple.domain.name"
$certPassword = "YourPassword"

# Create a self-signed certificate
$cert = New-SelfSignedCertificate -DnsName $dnsName -CertStoreLocation Cert:\LocalMachine\My
$thumbprint = $cert.Thumbprint

# Export the certificate
$certPath = "Cert:\LocalMachine\My\$thumbprint"
$pwd = ConvertTo-SecureString -String $certPassword -Force -AsPlainText

# Ensure the export directory exists
$exportPath = "C:\Temp"
if (-Not (Test-Path -Path $exportPath)) {
    New-Item -Path $exportPath -ItemType Directory
}

# Export the certificate
Export-PfxCertificate -Cert $certPath -FilePath "$exportPath\winrm.pfx" -Password $pwd

# Open the firewall port for WinRM HTTPS
New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "WinRM over HTTPS" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Configure the WinRM service
winrm quickconfig -q

# Create the WinRM listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$dnsName`";CertificateThumbprint=`"$thumbprint`"}"

# Verify the configuration
winrm enumerate winrm/config/listener
