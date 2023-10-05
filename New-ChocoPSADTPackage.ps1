[cmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $PackageName,

    [Parameter(Mandatory)]
    [ValidateScript({
        Test-Path $_
    })]
    [String]
    $PackageZip,

    [Parameter(Mandatory)]
    [String]
    $SoftwareName,

    [Parameter(Mandatory)]
    [ValidateSet('PSADT-Silent','PSADT-Install')]
    $Template,

    [Parameter()]
    [string]
    $PackageVersion = '1.0.0',

    [Parameter()]
    [String]
    $OutputDirectory = (Split-Path -Parent $MyInvocation.MyCommand.Definition),

    [Parameter()]
    [Switch]
    $BuildPackage
)

process {
    $PackageName = ($PackageName).ToLower()

    if($OutputDirectory){
        if(-not (Test-Path $OutputDirectory)){
            $null = New-Item $OutputDirectory -ItemType Directory
        }
    }

    $Zip = $PackageZip.Split('\')[-1]

    Write-Verbose "Received zip: $Zip"

    $chocoArgs = @('new',$PackageName,"--version='$PackageVersion'","--template='$Template'","--output-directory='$OutputDirectory'","Software=$SoftwareName","Zip=$Zip")

    Write-Verbose -Message "Received following arguments for choco; $($chocoArgs -join ' ')"

    
    & choco @chocoArgs

    $packageDirectory = Join-Path $OutputDirectory -ChildPath $PackageName
    $toolsDirectory = Join-Path $packageDirectory -ChildPath 'tools'

    Copy-Item $PackageZip -Destination $toolsDirectory
    
    if($BuildPackage){
       Push-Location $packageDirectory
       & choco pack
       Pop-Location
    }
}