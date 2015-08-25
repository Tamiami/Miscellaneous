param(
    [string]$rawRules
)

[xml]$rules = [xml](Get-Content $rawRules)


$ruleGroups = $rules.config.devices.entry.'device-group'.entry
[PSCustomObject]$securityRules = @()
foreach ($group in $ruleGroups) {
    $XMLSecurityRules = $group.'pre-rulebase'.security.rules.entry
    $XMLSecurityRules += $group.'post-rulebase'.security.rules.entry

   [PSCustomObject]$securityRules = @()
   foreach ($rule in $XMLSecurityRules) {
        $tmp = [PSCustomObject]@{
            Name = $rule.name
            From = $rule.source.member | Out-String
            To = $rule.destination.member | Out-String
            Description = $rule.description
        }

        $tmp.From = ($tmp.From -creplace '(?m)^\s*\r?\n', '').Trim()
        $tmp.To = ($tmp.To -creplace '(?m)^\s*\r?\n', '').Trim()

    $securityRules += $tmp
    }

    $securityRules | Export-CSV -PATH "$($group.name).csv"

    if ((Get-Random -Maximum 8) -eq 0) { [System.GC]::Collect() }
}