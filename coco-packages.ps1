 param (
    [switch]$List = $false,
    [switch]$Cleanup = $false
 )

if ($list -and $cleanup)
{
    Write-Host ("Cannot use both -List and -Cleanup at once.")
    Exit(1)
}

Function PackagesList($List)
{
    $PackageArray = @()
    $OldPackagesXml = Get-ChildItem $env:ProgramData"\chocolatey\lib" -Directory| Select FullName
    ForEach ($Folder in $OldPackagesXml)
    {
        $ChocoLibFolder = $env:ProgramData + "\chocolatey\lib\chocolatey"
        If ($Folder.FullName -ne $ChocoLibFolder)
        {
            $a = Split-Path ($Folder.FullName) -Leaf
            $FullFolderPath = $Folder.FullName
            $FullFilePath = "$FullFolderPath\$a.nuspec"
            [xml]$app = Get-Content ($FullFilePath)
            If ($List)
            {
                # Param = -List
                $PackageArray += $app.package.metadata.id + " " + $app.package.metadata.version
            }
            Else
            {
                # Param = -Cleanup
                $PackageArray += $env:ProgramData + "\chocolatey\.chocolatey\" + $app.package.metadata.id + "." + $app.package.metadata.version
            }
	    }
    }
    return $PackageArray
}


$AllPackages = PackagesList($List)

if ($list)
{
    ForEach ($Package in $AllPackages)
    {
        $Package
    }
}

if ($cleanup)
{
    $OldPackages = Get-ChildItem $env:ProgramData"\chocolatey\.chocolatey" -Directory| Select FullName
    $CleanupFolders = @()

    ForEach ($Folder in $OldPackages) 
    {
        If ($Folder.FullName -notin $AllPackages)
        {
            $CleanupFolders += $Folder.FullName
        }
    }

    If ($CleanupFolders.Count -eq 0)
    {
        Write-Host ("`r`n  **  NO legacy files in .chocolatey to delete.")
    }
    Else
    {
        $FolderDeleteCount = $CleanupFolders.Count

        $Response = Read-Host -Prompt ("`r`n  **  " + [String]$FolderDeleteCount + " folders can be deleted. Delete them now? [y/n]")
        if ($Response.ToLower() -eq 'y') {
            ForEach ($CleanupFolder in $CleanupFolders)
            {
                Remove-Item $CleanupFolder -Recurse
            }
        }
    }
}