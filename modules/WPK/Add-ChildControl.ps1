function Add-ChildControl
{
    <#
    .Synopsis
        Adds a Child Control to a panel
    .Description
        Adds a Child Control to a panel
    .Example
        New-StackPanel -On_Loaded {
            New-Label "Hello" | Add-ChildControl -parent $this
        }
    .Parameter control
        The UI Element to add to the parent
    .Parameter scriptBlock
        A Script Block used to create a UI Element to add 
    .Parameter parameters
        The parameters to the script block
    .Parameter parent
        The panel the child controls will be added into
    .Parameter passthru
        If set, the UI element will be returned through the pipeline.      
    #>
    [CmdletBinding(DefaultParameterSetName='Control')]    
    param(
    [Parameter(Mandatory=$true,ParameterSetName='Control',ValueFromPipeline=$true)]
    [Windows.UIElement]$control,

    [Parameter(Mandatory=$true,
        ParameterSetName='ScriptBlock',
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Alias('Definition')]
    [ScriptBlock]$scriptBlock,
    
    [Parameter(ParameterSetName='ScriptBlock', 
        ValueFromPipelineByPropertyName=$true)]    
    [Hashtable]$parameters,
        
    [Parameter(Position=0, 
        Mandatory=$true)]
    [Windows.Controls.Panel]$parent,
    
    [switch]$passThru
    )
    
    process {        
    
        if ($scriptBlock) {
            if ($parameters) {
                $control = & $scriptBlock @parameters
            } else {
                $control = & $scriptBlock
            }           
        }
                
        $null = $parent.Children.Add($control)
        if ($passThru) { $control } 
    }
}