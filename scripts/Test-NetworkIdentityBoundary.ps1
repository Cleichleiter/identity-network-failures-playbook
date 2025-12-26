<#
.SYNOPSIS
  Lightweight boundary test: Network vs Identity.

.DESCRIPTION
  Runs minimal checks to determine whether an issue is primarily:
   - NETWORK/DNS PATH (stop identity work), or
   - IDENTITY PATH (proceed to identity decision tree), or
   - NO DOMAIN CONTEXT (device not domain-joined / domain unavailable).

  Outputs objects with PASS/FAIL/INFO plus a final classification.

.PARAMETER Domain
  DNS domain name to validate (defaults to current AD domain if joined).

.PARAMETER Dc
  Domain Controller to test (optional). If not provided, script tries to discover one.

.PARAMETER DnsServers
  Optional DNS servers to test resolution against (ex: 10.0.0.10,10.0.0.11).

.PARAMETER Ports
  Ports to test to the DC (defaults: 53, 88, 389, 445, 135).

.PARAMETER OutputJson
  If set, outputs JSON (good for ticket pasting).

.EXAMPLE
  .\Test-NetworkIdentityBoundary.ps1 -Verbose

.EXAMPLE
  .\Test-NetworkIdentityBoundary.ps1 -Domain contoso.com -Dc dc01.contoso.com -OutputJson
#>

[CmdletBinding()]
param(
  [string]$Domain,
  [string]$Dc,
  [string[]]$DnsServers,
  [int[]]$Ports = @(53,88,389,445,135),
  [switch]$OutputJson
)

function Add-Result {
  param(
    [string]$Test,
    [string]$Type,
    [string]$Target,
    [bool]$Result,
    [string]$Status,
    [string]$Notes
  )

  if ($null -eq $Notes) { $Notes = "" }

  [pscustomobject]@{
    Test   = $Test
    Type   = $Type
    Target = $Target
    Result = $Result
    Status = $Status
    Notes  = $Notes
  }
}

function Has-Fail {
  param(
    [System.Collections.IEnumerable]$Results,
    [string]$TestPrefix
  )
  $count = ($Results | Where-Object { $_.Test -like ($TestPrefix + "*") -and $_.Status -eq "FAIL" } | Measure-Object).Count
  return ($count -gt 0)
}

$results = New-Object System.Collections.Generic.List[object]

Write-Verbose "Starting Network vs Identity boundary test"

# --- Basic IP/Gateway checks ---
$gw = $null
try {
  $ipCfg = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1

  if (-not $ipCfg) {
    $results.Add((Add-Result -Test "IPv4 Address Present" -Type "Network" -Target "Local" -Result $false -Status "FAIL" -Notes "No active IPv4 adapter detected"))
  } else {
    $ip = $ipCfg.IPv4Address.IPAddress
    $gw = $null
    if ($ipCfg.IPv4DefaultGateway) { $gw = $ipCfg.IPv4DefaultGateway.NextHop }

    $isApipa = $false
    if ($ip -like "169.254.*") { $isApipa = $true }

    if ($isApipa) {
      $results.Add((Add-Result -Test "IPv4 Address Present" -Type "Network" -Target $ip -Result $false -Status "FAIL" -Notes "APIPA detected"))
    } else {
      $results.Add((Add-Result -Test "IPv4 Address Present" -Type "Network" -Target $ip -Result $true -Status "PASS" -Notes "" ))
    }

    $gwTarget = $gw
    if (-not $gwTarget) { $gwTarget = "None" }

    $results.Add((Add-Result -Test "Default Gateway Present" -Type "Network" -Target $gwTarget -Result ([bool]$gw) -Status ( $(if($gw){"PASS"}else{"FAIL"}) ) -Notes "" ))
  }
} catch {
  $results.Add((Add-Result -Test "IP Configuration Read" -Type "Network" -Target "Local" -Result $false -Status "FAIL" -Notes $_.Exception.Message))
}

# Ping default gateway (if present)
if ($gw) {
  $gwPing = Test-Connection -ComputerName $gw -Count 1 -Quiet -ErrorAction SilentlyContinue
  $results.Add((Add-Result -Test "Default Gateway Reachable" -Type "Network" -Target $gw -Result $gwPing -Status ( $(if($gwPing){"PASS"}else{"FAIL"}) ) -Notes "" ))
}

# --- Domain detection (if not provided) ---
if (-not $Domain) {
  try {
    $cs = Get-CimInstance Win32_ComputerSystem
    if ($cs.PartOfDomain -and $cs.Domain) {
      $Domain = $cs.Domain
      Write-Verbose ("Detected domain: {0}" -f $Domain)
      $results.Add((Add-Result -Test "Domain Detected" -Type "Identity" -Target $Domain -Result $true -Status "INFO" -Notes "" ))
    } else {
      $results.Add((Add-Result -Test "Domain Detected" -Type "Identity" -Target "N/A" -Result $false -Status "INFO" -Notes "Device not domain-joined or domain unavailable"))
    }
  } catch {
    $results.Add((Add-Result -Test "Domain Detected" -Type "Identity" -Target "Unknown" -Result $false -Status "INFO" -Notes $_.Exception.Message))
  }
} else {
  $results.Add((Add-Result -Test "Domain Provided" -Type "Identity" -Target $Domain -Result $true -Status "INFO" -Notes "Domain specified via parameter"))
}

# --- DNS checks ---
if ($Domain) {

  # DNS resolve domain (optionally against specified DNS servers)
  if ($DnsServers -and $DnsServers.Count -gt 0) {
    foreach ($dns in $DnsServers) {
      $ok = $false
      try {
        Resolve-DnsName -Name $Domain -Server $dns -ErrorAction Stop | Out-Null
        $ok = $true
      } catch {
        $ok = $false
      }

      $results.Add((Add-Result -Test "DNS Resolve Domain" -Type "DNS" -Target ("{0} via {1}" -f $Domain,$dns) -Result $ok -Status ( $(if($ok){"PASS"}else{"FAIL"}) ) -Notes "" ))
    }
  } else {
    $ok = $false
    try {
      Resolve-DnsName -Name $Domain -ErrorAction Stop | Out-Null
      $ok = $true
    } catch {
      $ok = $false
    }

    $results.Add((Add-Result -Test "DNS Resolve Domain" -Type "DNS" -Target $Domain -Result $ok -Status ( $(if($ok){"PASS"}else{"FAIL"}) ) -Notes "" ))
  }

  # SRV record check for Kerberos KDC
  $srvOk = $false
  $srvName = "_kerberos._tcp.{0}" -f $Domain
  try {
    Resolve-DnsName -Name $srvName -Type SRV -ErrorAction Stop | Out-Null
    $srvOk = $true
  } catch {
    $srvOk = $false
  }

  $results.Add((Add-Result -Test "DNS SRV Record Present" -Type "DNS" -Target $srvName -Result $srvOk -Status ( $(if($srvOk){"PASS"}else{"FAIL"}) ) -Notes "Kerberos depends on SRV records" ))
}

# --- DC discovery (optional) ---
if (-not $Dc -and $Domain) {
  try {
    $nl = & nltest /dsgetdc:$Domain 2>$null
    if ($LASTEXITCODE -eq 0 -and $nl) {
      $dcLine = ($nl | Select-String -Pattern "DC:" -SimpleMatch).Line
      if ($dcLine) {
        $Dc = ($dcLine -replace ".*DC:\s*", "").Trim()
      }
    }
  } catch { }

  if (-not $Dc) {
    # Best-effort fallback: try a SRV lookup for LDAP/DC
    try {
      $ldapSrv = Resolve-DnsName -Name ("_ldap._tcp.dc._msdcs.{0}" -f $Domain) -Type SRV -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($ldapSrv -and $ldapSrv.NameTarget) {
        $Dc = $ldapSrv.NameTarget.TrimEnd('.')
      }
    } catch { }
  }

  if ($Dc) {
    $results.Add((Add-Result -Test "Domain Controller Selected" -Type "Identity" -Target $Dc -Result $true -Status "INFO" -Notes "" ))
    Write-Verbose ("Selected DC: {0}" -f $Dc)
  } else {
    $results.Add((Add-Result -Test "Domain Controller Selected" -Type "Identity" -Target "None" -Result $false -Status "INFO" -Notes "Could not auto-discover a DC"))
  }
}

# --- DC reachability + port tests ---
if ($Dc) {
  $dcPing = Test-Connection -ComputerName $Dc -Count 1 -Quiet -ErrorAction SilentlyContinue
  $results.Add((Add-Result -Test "DC Reachable (Ping)" -Type "Network" -Target $Dc -Result $dcPing -Status ( $(if($dcPing){"PASS"}else{"FAIL"}) ) -Notes "" ))

  foreach ($p in $Ports) {
    $pOk = $false
    try {
      $pOk = Test-NetConnection -ComputerName $Dc -Port $p -InformationLevel Quiet -WarningAction SilentlyContinue
    } catch {
      $pOk = $false
    }

    $target = "{0}:{1}" -f $Dc, $p
    $results.Add((Add-Result -Test "Port Test" -Type "Port" -Target $target -Result $pOk -Status ( $(if($pOk){"PASS"}else{"FAIL"}) ) -Notes "" ))
  }
}

# --- Domain context check (if no domain, classification should not be IDENTITY PATH) ---
$domainMissing = $false
$domainDetectedItem = $results | Where-Object { $_.Test -eq "Domain Detected" } | Select-Object -First 1
if ($domainDetectedItem -and $domainDetectedItem.Result -eq $false -and -not $PSBoundParameters.ContainsKey('Domain')) {
  $domainMissing = $true
}

# --- Boundary classification ---
$networkFail = $false

if (Has-Fail -Results $results -TestPrefix "IPv4 Address Present")        { $networkFail = $true }
if (Has-Fail -Results $results -TestPrefix "Default Gateway Present")     { $networkFail = $true }
if (Has-Fail -Results $results -TestPrefix "Default Gateway Reachable")   { $networkFail = $true }
if (Has-Fail -Results $results -TestPrefix "DNS Resolve Domain")          { $networkFail = $true }
if (Has-Fail -Results $results -TestPrefix "DNS SRV Record Present")      { $networkFail = $true }
if (Has-Fail -Results $results -TestPrefix "DC Reachable")                { $networkFail = $true }

# Core ports: Kerberos 88, LDAP 389, SMB 445
$corePorts = @(88,389,445)
$corePortFails = $results | Where-Object {
  $_.Test -eq "Port Test" -and $_.Status -eq "FAIL" -and ($corePorts -contains ([int]($_.Target.Split(':')[-1])))
}
if (($corePortFails | Measure-Object).Count -gt 0) { $networkFail = $true }

$classification = "IDENTITY PATH"
$summaryNote = "Boundary checks passed. Proceed to identity decision tree (time/Kerberos/trust/user policy)."

if ($domainMissing) {
  $classification = "NO DOMAIN CONTEXT"
  $summaryNote = "Device is not domain-joined (or domain unavailable). Provide -Domain/-Dc (or connect VPN/on-site) before proceeding with identity checks."
} elseif ($networkFail) {
  $classification = "NETWORK/DNS PATH"
  $summaryNote = "One or more boundary checks failed. Fix network/DNS path before identity changes."
}

$results.Add([pscustomobject]@{
  Test   = "Boundary Classification"
  Type   = "Summary"
  Target = "Overall"
  Result = $true
  Status = $classification
  Notes  = $summaryNote
})

if ($OutputJson) {
  $results | ConvertTo-Json -Depth 4
} else {
  $results
}

