function Uninstall-IISCrypto {
    <#
	.SYNOPSIS
		Uninstalls the IISCrypto application from the local machine.
	
	.DESCRIPTION
		Locates the IISCrypto installation directory from the Machine PATH environment
		variable, removes the directory recursively, and removes the entry from the
		Machine PATH. The function refuses to act unless the resolved path is non-empty,
		contains 'IISCrypto', and exists on disk. All destructive operations are gated
		with ShouldProcess so -WhatIf and -Confirm behave as expected.
	
	.EXAMPLE
		Uninstall-IISCrypto -WhatIf
		Shows what would be removed without making any changes.
	
	.EXAMPLE
		Uninstall-IISCrypto -Confirm:$false
		Removes the IISCrypto installation directory and PATH entry without prompting.
	
	.NOTES
		Requires elevation to modify the Machine PATH environment variable and to
		remove files under %ProgramFiles%. The install directory is resolved via
		Get-EnvPath -Container Machine; the value is used as-is and never split.
	
	.LINK
		https://www.nartac.com/Products/IISCrypto
	#>
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]
    param ()
	
    begin {
		
    }
	
    process {
        $EnvPath = Get-EnvPath -Container Machine | Where-Object -FilterScript { $_ -like '*IISCrypto*' } | Select-Object -First 1
		
        if ([string]::IsNullOrWhiteSpace($EnvPath)) {
            Write-Output "IISCrypto is not installed on this machine"
            return
        }
		
        if ($EnvPath -notlike '*IISCrypto*') {
            Write-Warning "Resolved PATH entry '$EnvPath' does not reference IISCrypto. Aborting uninstall."
            return
        }
		
        if (-not (Test-Path -Path $EnvPath)) {
            Write-Warning "IISCrypto PATH entry '$EnvPath' does not exist on disk. Removing stale PATH entry only."
            if ($PSCmdlet.ShouldProcess($EnvPath, 'Remove stale IISCrypto entry from Machine PATH')) {
                Remove-EnvPath -Path $EnvPath -Container Machine
            }
            return
        }
		
        if ($PSCmdlet.ShouldProcess($EnvPath, 'Remove IISCrypto installation directory')) {
            Remove-Item -Path $EnvPath -Recurse -Force
        }
		
        if ($PSCmdlet.ShouldProcess($EnvPath, 'Remove IISCrypto entry from Machine PATH')) {
            Remove-EnvPath -Path $EnvPath -Container Machine
        }
		
        Write-Output "IISCrypto is uninstalled from this machine"
    }
	
    end {
		
    }
}
