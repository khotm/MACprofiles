# Define the URL of the self-signed certificate in your GitHub repository (RAW URL)
$githubCertUrl = "https://raw.githubusercontent.com/khotm/cert/main/*.gh.pri.cer"  # Replace with the actual URL
$certPath = "C:\temp\ghpri.cer"

# Test if GitHub is reachable on port 443 (HTTPS)
$connectionTest = Test-NetConnection -ComputerName "github.com" -Port 443

if ($connectionTest.TcpTestSucceeded) {
    Write-Host "Connection to GitHub on port 443 succeeded. Proceeding with certificate retrieval..."

    # Download the certificate from the GitHub repository
    try {
        Invoke-WebRequest -Uri $githubCertUrl -OutFile $certPath
        Write-Host "Certificate successfully downloaded to $certPath"
    } catch {
        Write-Host "Failed to download the certificate: $_"
        return
    }

    # Import the downloaded certificate into the Trusted Root Certification Authorities store
    try {
        # Open the LocalMachine Root store
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

        # Import the downloaded certificate
        $newCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $newCert.Import($certPath)

        # Add the certificate to the store
        $store.Add($newCert)

        # Close the store after adding the certificate
        $store.Close()

        Write-Host "Certificate successfully imported into Trusted Root Certification Authorities"
    }
    catch {
        Write-Host "Failed to import the certificate: $_"
    }
} else {
    Write-Host "Failed to connect to GitHub on port 443. Please check your network connection."
}
