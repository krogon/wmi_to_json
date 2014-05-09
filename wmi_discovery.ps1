if ($args.count -ne 2) {
    Write-Host "Usage:"$MyInvocation.MyCommand.Name"<namespace> <WMI querry>"
    exit 1
}

$Databases = Get-WmiObject -Namespace "$($args[0])" -query "$($args[1])"
if (-not $?) {
    Write-Host "WMI Query failed"
    exit 1
}

if ($Databases -eq $null) {
    Write-Host "Empty result"
    exit 1
}

Write-Host "{"
Write-Host "`t`"data`":[`n"

$first=1
foreach ($dbase in $Databases) {
    if (-not $first) {
        Write-Host "`t,"
    }
    $first=0
    Write-Host "`t{"
    
    $properties = $dbase.psobject.properties | where-object {$_.name -eq "Properties"}
    $prop_size = $properties.Value.Count
    $subitem = 1
    foreach ($field in $properties.Value) {
        $name = $field.Name.ToUpper()
        $value = $field.Value
        Write-Host -NoNewline "`t`t`"{#$name}`":`"$value`""
        
        if ($subitem -ne $prop_size) {
            Write-Host ","
        }
        else {
            Write-Host ""
        }
        $subitem++
    }
    Write-Host "`t}"
}

Write-Host "`n`t]"
Write-Host "}"