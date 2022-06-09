#!/usr/bin/env pwsh
Param (
    [Parameter(Mandatory)][string][ValidateSet("xml", "json")]$Format
)
$ErrorActionPreference="Stop"

Set-Variable -Name OutputDirectory -Value (Join-Path -Path $PSScriptRoot -ChildPath dest) -Option ReadOnly -ErrorAction Stop
if(-not (Test-Path -Path $OutputDirectory))
{
    New-Item -ItemType Directory -Path $OutputDirectory > $null
}

docker compose down --volumes 2> $null
docker compose up --quiet-pull --detach 2> $null

docker compose exec ddl-to-schema bash -c "/bundle/extract.sh ${Format}"

docker compose down --volumes 2> $null

Write-Output -InputObject "schemas generated at ${OutputDirectory}/${Format}"
