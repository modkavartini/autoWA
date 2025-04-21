
<#
edit $text1 etc. accordingly.
valid variables are:
$user
$search
$v1
and more
which can be custom text(s) for each user
#>

set-Location $pSScriptRoot
add-Type -assemblyName system.Windows.Forms
add-Type -assemblyName system.Drawing

function sendEmAll {
    param (
        [string]
        $csv = ".\data.csv"
    )
    
    $e = 0
    $file = import-CSV $csv | group-Object user
    $file | forEach-Object { $e++ }
    #$imagePath = "$pSScriptRoot\img.jpeg"

    if ($e -eq 0) {
        write-Error "0 entries found!"
        exit
    }
    write-Host "`n$e entries found! starting in 5. ctrl+c to exit.`n"  -foregroundColor green
    write-Host "warning! hands off the keyboard/mouse or you'll mess it up!`n"  -foregroundColor yellow

    for ($t = 5; $t -ne -1; $t--) {
        write-Host "$t" -foregroundColor red
        waitFor 1
    }

    write-Host "`nstarting...`n"  -foregroundColor green

    #sendKey lwin+d
    .\nircmd.exe win min title "WhatsApp"
    .\nircmd.exe win max title "WhatsApp"
    .\nircmd.exe win settopmost title "WhatsApp" 1
    waitFor 1
    $i = 0

    $file | forEach-Object {

        $user = $_.group[0].user
        $search = $_.group[0].search
        #$v1 = $_.group[0].v1
        #can add more vars as needed, with reference to the .csv file

        #editable parts start here.
        if ($user.length -gt 1) {
            write-Host "sending to $user...`n" -foregroundColor blue
            write-Host "#$($i) of $e`n" -foregroundColor green

            $text1 = get-Content ".\mainMessage.txt"

            start-Process https://api.whatsapp.com/send?phone=91$search
            waitFor 3
            if(onWhatsApp) {
                pasteAndEnter $text1
                waitFor 2
                $i++
            }
            else {
                sendKey enter
                sendKey esc
                write-Host "the phone number isn't on whatsapp." -foregroundColor blue
                $i++
            }
        }
    }
    sendKey esc
    .\nircmd.exe win settopmost title "WhatsApp" 0
    write-Host "sent to all $i of $e users!"  -foregroundColor green
}

#my loyal helpers...

function waitFor($t) {
    start-Sleep $t
}

function sendKey($k) {
    waitFor 1
    .\nircmd.exe sendkeypress $k
    waitFor 1
}

function pasteAndEnter($text) {
    set-Clipboard $text
    waitFor 1
    sendKey ctrl+v
    waitFor 3
    sendKey enter
}

function goAndClick($x, $y) {
    nircmd.exe setcursor $x $y
    nircmd.exe sendmouse left click
    waitFor 1
}

function onWhatsApp {
    $x = 710
    $y = 445
    $w = 500
    $h = 100
    $bitmap = new-Object system.Drawing.Bitmap $w, $h
    $graphics = [system.Drawing.Graphics]::fromImage($bitmap)
    $graphics.copyFromScreen($x, $y, 0, 0, [system.Drawing.Size]::new($w, $h))
    $bitmap.Save("C:\Temp\cropped.png", [system.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()

    $result = & "C:\Program Files\Tesseract-OCR\tesseract.exe" C:\Temp\cropped.png stdout --psm 6
    if ($result -match "isn't on WhatsApp") { return 0 }
    else { return 1 }
}

#run
sendEmAll