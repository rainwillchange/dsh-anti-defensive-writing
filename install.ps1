#Requires -Version 5.1
<#
.SYNOPSIS
  Copy the Anti-Defensive Writing skills into a dsh (DeepSeek Harness) skills
  directory, for hosts that load skills from disk instead of installing the
  plugin bundle.

.DESCRIPTION
  Copies skills/anti-defensive-writing and skills/anti-defensive-writing-en into
  <Dest>/<skill-name>/SKILL.md. The default destination is
  $env:DSH_HOME\skills when DSH_HOME is set, otherwise $HOME\.dsh\skills.
  Passing -Dest "~\.agents\skills" installs for every compatible agent instead.

  For the plugin route, prefer: dsh plugin --profile <profile> add <this-folder>

.PARAMETER Dest
  Parent skills directory. Default: $env:DSH_HOME\skills, else $HOME\.dsh\skills.

.PARAMETER Force
  Replace existing skill folders.

.PARAMETER Help
  Show this help.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Dest,
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    return
}

$here = $PSScriptRoot
$skills = @('anti-defensive-writing', 'anti-defensive-writing-en')

foreach ($skill in $skills) {
    $source = Join-Path $here "skills\$skill\SKILL.md"
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Missing bundled skill file: $source"
    }
}

if (-not $Dest) {
    $dshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $HOME '.dsh' }
    $Dest = Join-Path $dshHome 'skills'
} elseif ($Dest -eq '~') {
    $Dest = $HOME
} elseif ($Dest.StartsWith('~/') -or $Dest.StartsWith('~\')) {
    $Dest = Join-Path $HOME $Dest.Substring(2)
}

$Dest = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Dest)
[System.IO.Directory]::CreateDirectory($Dest) | Out-Null

foreach ($skill in $skills) {
    $target = Join-Path $Dest $skill
    $existing = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    if ($existing -and ($existing.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Destination is a link: $target. Choose another directory."
    }
    if ($existing -and -not $Force) {
        throw "Destination already exists: $target. Use -Force to replace it."
    }

    $staging = Join-Path $Dest ".$skill.tmp.$([guid]::NewGuid().ToString('N'))"
    [System.IO.Directory]::CreateDirectory($staging) | Out-Null
    try {
        Copy-Item -LiteralPath (Join-Path $here "skills\$skill\SKILL.md") -Destination (Join-Path $staging 'SKILL.md')
        if ((Get-Content -LiteralPath (Join-Path $staging 'SKILL.md') -TotalCount 1) -ne '---') {
            throw "Invalid SKILL.md: missing YAML frontmatter ($skill)."
        }
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        Move-Item -LiteralPath $staging -Destination $target
        Write-Host "Installed $target\SKILL.md"
    } finally {
        if (Test-Path -LiteralPath $staging) {
            Remove-Item -LiteralPath $staging -Recurse -Force
        }
    }
}

Write-Host "Done. Restart dsh or wait for its skill watcher to pick up $Dest."
