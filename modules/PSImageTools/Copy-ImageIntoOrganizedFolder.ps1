#requires -version 2.0
function Copy-ImageIntoOrganizedFolder
{
    <#
    .Synopsis
    Copies images into folders organized by characteristics that you specify.

    .Description
    The Copy-ImageIntoOrganizedFolder function uses properties or script blocks that you specify to create folders on disk. 
    Then it copies the image files into the correct folders based on their property values.

    Use the Path parameter to specify the image files to copy. 
    The Include, Exclude, Filter, and Recurse parameters qualify the Path parameter. 
    These parameter work in Copy-ImageIntoOrganizedFolders in the same way that they work in the Get-ChildItem cmdlet.

    Use the Property and ScriptBlock parameters to establish criteria for organizing the image files into folders.

    Copy-ImageIntoOrganizedFolder calls both the Get-Image and Get-ImageProperty functions on every image that you submit.
    Therefore, you can use the basic properties that Get-Image gets or the extended properties that Get-ImageProperty gets to organize your images.

    .Parameter Path
    [Required] Specifies the path to the image files. 
    Enter the path (optional) and file name or file name pattern. 
    Wildcards are permitted. 
    The default location is the current directory (.).
    This parameter is required.

    .Parameter Property
    Specifies the properties that you use to organize the folders.

    .Parameter ScriptBlock
    The results of a script block used to group the photos

    .Parameter Filter
    Specifies a filter in the provider's format or language.
    The value of this parameter qualifies the Path parameter.
    The syntax of the filter, including the use of wildcards, depends on the provider.
    Filters are more efficient than other parameters, 
    because the provider applies them when it gets the objects, 
    rather than having Windows PowerShell filter the objects after they are retrieved. 

    .Parameter Include
    Retrieves only the specified items. The value of this parameter qualifies 
    the Path parameter. Enter a path element or pattern, such as "*.txt". 
    Wildcards are permitted.
            
    The Include parameter is effective only when the command includes the contents 
    of an item, such as C:\Windows\*, where the wildcard character specifies the 
    contents of the C:\Windows directory.

    .Parameter Exclude
    Omits the specified items. The value of this parameter qualifies the Path 
    parameter. Enter a path element or pattern, such as "*.txt". Wildcards are permitted.
            
    The Exclude parameter is effective only when the command includes the 
    contents of an item, such as C:\Windows\*, where the wildcard character specifies the
    contents of the C:\Windows directory.    

    .Parameter Recurse
    Gets the items in the specified locations and in all child items of the locations. 
        
    Recurse works only when the path points to a container that has child items, 
    such as C:\Windows or C:\Windows\*, and not when it points to items 
    that do not have child items, such as C:\Windows\*.exe.

    .Parameter HideProgress
    If set, will not show progress bars

    .Example
    # Copies photos into directories for each month and year.
    C:\PS> Copy-ImageIntoOrganizedFolder $env:UserProfile\Pictures -ScriptBlock {$_.DateTime.Month}, {$_.DateTime.Year } –Recurse
         
     
    .Example
    # Copies photos into a directories based on the camera  make and model.
    Copy-ImageIntoOrganizedFolder -Path $env:UserProfile\Pictures -Property "EquipMake","EquipModel"

    .Link
    Get-Image

    .Link
    Get-ImageProperty

    .Link
    Get-ChildItem

    #>
    [CmdletBinding(DefaultParameterSetName='Property')]
    param(
    [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $Path,
    
    [Parameter(ParameterSetName='Property',
        Mandatory=$true,
        Position=1)]
    [String[]]
    $Property,


    [Parameter(ParameterSetName='ScriptBlock',
        Mandatory=$true,
        Position=1)]
    [ScriptBlock[]]
    $ScriptBlock,

    [String]
    $Filter,

    [String[]]
    $Include,

    [String[]]
    $Exclude,

    [Switch]
    $Recurse,

    [Switch]
    $HideProgress)
    
    process {
        $GetChildItemParameters = @{
            Path = $psBoundParameters.Path
            Filter = $psBoundParameters.Filter
            Include = $psBoundParameters.Include
            Exclude = $psBoundParameters.Exclude
            Recurse = $psBoundParameters.Recurse
        }
        Get-ChildItem @GetChildItemParameters |
            Get-Image | 
            Get-ImageProperty |
            Copy-Item -Path { $_.FullName } -Destination {
                $newPath = ""
                $item  = $_
                if ($psCmdlet.ParameterSetName -eq "Property") {
                    foreach ($p in $property) {
                        $newPath = $newPath + ' ' + $_.$p
                    }                                        
                } else {
                    if ($psCmdlet.ParameterSetName -eq "ScriptBlock") {
                        foreach ($s in $scriptBlock) {
                            $newPath = $newPath + ' ' + (& $s)
                        }                    
                    }
                }
                if (-not $newPath.Trim()) { return }
                $newPath = $newPath.Trim() 
                $destPath = Join-Path $path $newPath
                if (-not (Test-Path $destPath)) { 
                    $null = New-Item $destPath -Force -Type Directory
                }
                $leaf = Split-Path $_.FullName -Leaf
                $fullPath = Join-Path $destPath $leaf
                if (-not $HideProgress) { 
                    $script:percent += 5
                    if ($script:percent -gt 100) { $script:percent = 0 } 
                    Write-Progress $_.FullName $fullPath -PercentComplete $percent
                }
                $fullPath
            } -ErrorAction SilentlyContinue
        
    }
}
 
