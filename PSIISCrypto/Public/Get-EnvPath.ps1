function Get-EnvPath {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Machine', 'User', 'Process')]
        [string] $Container
    )
    $containerMapping = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User    = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
    }
    $containerType = $containerMapping[$Container]
    [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';' |
    Where-Object { $_ }
}
