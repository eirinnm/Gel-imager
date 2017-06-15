param (
    [string]$dir = "C:\Users\Gel imager\Pictures\Camera Roll"
)
#Write-host $dir
#write-host $PSScriptRoot
## Get the newest image in this folder:
$img = Get-ChildItem $dir -Filter *.jpg | Sort-Object LastWriteTime -Descending | Select-Object -first 1
if($img){
  $imgpath = join-path ($dir) $img
}

## Read a list of email addresses
$emailfilename = join-path ($PsScriptRoot) EmailAddresses.txt
[System.Collections.ArrayList]$names = Get-Content $emailfilename


Add-Type -AssemblyName System.Windows.Forms


$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Photo emailer"
$Form.TopMost = $true
$Form.Width = 441
$Form.Height = 567
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog


$label2 = New-Object system.windows.Forms.Label
$label2.Text = "To whom do you wish to send this image?"
$label2.AutoSize = $true
$label2.Width = 25
$label2.Height = 10
$label2.location = new-object system.drawing.point(12,17)
$label2.Font = "Microsoft Sans Serif,14"
$Form.controls.Add($label2)


$comboBox3 = New-Object system.windows.Forms.ComboBox
$comboBox3.Text = "email address"
$comboBox3.Width = 400
$comboBox3.Height = 20
$comboBox3.location = new-object system.drawing.point(12,44)
$comboBox3.Font = "Microsoft Sans Serif,14"
$Form.controls.Add($comboBox3)
if($names){
$comboBox3.Items.AddRange($names)
#$comboBox3.DisplayMember = $
$comboBox3.SelectedIndex = 0
}


$PictureBox4 = New-Object system.windows.Forms.PictureBox
$PictureBox4.Width = 400
$PictureBox4.Height = 400
$PictureBox4.BackColor = [System.Drawing.Color]::Transparent
$PictureBox4.Width = 400
$PictureBox4.Height = 400
$PictureBox4.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$PictureBox4.location = new-object system.drawing.point(12,80)
$Form.controls.Add($PictureBox4)
if($img){
$PictureBox4.ImageLocation = $imgpath
}


$label5 = New-Object system.windows.Forms.Label
$label5.Text = "Image path"
$label5.AutoSize = $true
$label5.ForeColor = "#ffffff"
$label5.Width = 25
$label5.Height = 10
$label5.location = new-object system.drawing.point(5,10)
$label5.Font = "Microsoft Sans Serif,10"
$PictureBox4.controls.Add($label5)
if($img){
  $label5.text = $img
}else{
$label5.text = "No image found!"
}

$btnSend = New-Object system.windows.Forms.Button
$btnSend.Text = "Send"
$btnSend.Width = 60
$btnSend.Height = 30
$btnSend.location = new-object system.drawing.point(275,488)
$btnSend.Font = "Microsoft Sans Serif,10"
$btnSend.DialogResult = "OK"
$Form.controls.Add($btnSend)


$btnCancel = New-Object system.windows.Forms.Button
$btnCancel.Text = "Cancel"
$btnCancel.Width = 60
$btnCancel.Height = 30
$btnCancel.location = new-object system.drawing.point(350,488)
$btnCancel.Font = "Microsoft Sans Serif,10"
$btnCancel.DialogResult = "Cancel" 
$Form.controls.Add($btnCancel)

$form.AcceptButton = $btnSend          # ENTER = Ok 
$form.CancelButton = $btnCancel      # ESCAPE = Cancel 

## Rest of code continues after these declarations

#=====================================================================
# Get-MyCredential: retrieve or store username and password
#=====================================================================
function Get-MyCredential
{
param(
$CredPath,
[switch]$Help
)
$HelpText = @"

    Get-MyCredential
    Usage:
    Get-MyCredential -CredPath `$CredPath

    If a credential is stored in $CredPath, it will be used.
    If no credential is found, Export-Credential will start and offer to
    Store a credential at the location specified.

"@
    if($Help -or (!($CredPath))){write-host $Helptext; Break}
    if (!(Test-Path -Path $CredPath -PathType Leaf)) {
        Export-Credential (Get-Credential) $CredPath
    }
    $cred = Import-Clixml $CredPath
    $cred.Password = $cred.Password | ConvertTo-SecureString
    $Credential = New-Object System.Management.Automation.PsCredential($cred.UserName, $cred.Password)
    Return $Credential
}

#=====================================================================
# Export-Credential
# Usage: Export-Credential $CredentialObject $FileToSaveTo
#=====================================================================
function Export-Credential($cred, $path) {
      $cred = $cred | Select-Object *
      $cred.password = $cred.Password | ConvertFrom-SecureString
      $cred | Export-Clixml $path
} 


$result = $form.ShowDialog()
if($result -eq "OK") {   
  if($img){   
    $email = $comboBox3.Text
    ## remove the current name and insert it at the top of the list
    $names.remove($email)
    $names.insert(0,$email)
    $names > $emailfilename
    #okay, now we email the file!
    $label2.text = "Sending..."
    $Credentials = Get-MyCredential (join-path ($PsScriptRoot) EmailPassword.xml)
    Send-MailMessage -From firstfloorgels@gmail.com -Subject "Your gel image is here" -To $email -Attachments $imgpath `
                     -Credential $Credentials `
                     -Port 587 `
                     -SmtpServer smtp.gmail.com `
                     -UseSsl
  }
}  
$Form.Dispose()
