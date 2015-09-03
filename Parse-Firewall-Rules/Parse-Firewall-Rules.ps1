Function Parse-Firewall-Rules($rawRules) {
	[xml]$rules = [xml](Get-Content $rawRules)
	[string]$saveRoot = File-Dialog($TRUE)

	$hosts = @()

	foreach ($entry in $XMLHosts.entry) {
		$aHost = [PSCustomObject]@{
			Hostname = $entry.name
			IP = $entry.'ip-netmask'
			Location = $entry.tag.member
			Description = $entry.description
		}
		$hosts += $aHost
	}

	$ruleGroups = $rules.config.devices.entry.'device-group'.entry
	[PSCustomObject]$securityRules = @()
	foreach ($group in $ruleGroups) {
		$XMLSecurityRules = $group.'pre-rulebase'.security.rules.entry
		$XMLSecurityRules += $group.'post-rulebase'.security.rules.entry

	   [PSCustomObject]$securityRules = @()
	   foreach ($rule in $XMLSecurityRules) {
			$tmp = [PSCustomObject]@{
				Name = $rule.name
				Action = $rule.action
				From = Clean-String($rule.source.member | Out-String)
				To = Clean-String($rule.destination.member | Out-String)
				Description = $rule.description
				Application = Clean-String($rule.application.member | Out-String)
				Service = Clean-String($rule.service.member | Out-String)
			}
			
		$securityRules += $tmp
		}

		$securityRules | Export-CSV -PATH "$($saveRoot)\$($group.name).csv"
		if ((Get-Random -Maximum 8) -eq 0) { [System.GC]::Collect() }
	}
}

Function Clean-String($str) {
	return ($str -creplace '(?m)^\s*\r?\n', '').Trim()
}

Function File-Dialog($save) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
	if ($save -eq $TRUE) {
		$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
		$dialog.SelectedPath = $PSScriptRoot
		$dialog.ShowDialog() | Out-Null
		$dialog.SelectedPath
	} else {
		$dialog = New-Object System.Windows.Forms.OpenFileDialog
		$dialog.InitialDirectory = $PSScriptRoot
		$dialog.ShowDialog() | Out-Null
		$dialog.Filename
	}		
}


#File-Dialog($FALSE)
Parse-Firewall-Rules(File-Dialog($FALSE))