#requires -Version 7

function New-NPMScript {
    param(
        [string] $ScriptName,
        [string] $ScriptCommand,
        [string] $PackageJsonPath
    )

    # Read the existing package.json file
    $packageJson = Get-Content $PackageJsonPath | ConvertFrom-Json
    Add-Member -InputObject $packageJson.scripts -MemberType NoteProperty -Name $ScriptName -Value $ScriptCommand;
    $packageJson | ConvertTo-Json | Set-Content $PackageJsonPath

    Write-Host "[x] Added script $ScriptName to package.json" -ForegroundColor Green
}

function Start-VisualStudioCode {
    param(
        [string] $Folder
    )

    Write-Host "[x] Opening project in Visual Studio Code." -ForegroundColor Green

    # Check if the user has insiders installed
    $codeInsiders = Get-Command -Name code-insiders -ErrorAction SilentlyContinue

    if ($null -eq $codeInsiders) {
        Write-Host "[x] Visual Studio Code Insiders is not installed, falling back to Visual Studio Code." -ForegroundColor Yellow
        $codeInsiders = Get-Command -Name code -ErrorAction SilentlyContinue
    }

    if ($null -eq $codeInsiders) {
        Write-Host "[x] Visual Studio Code is not installed, please install it and try again." -ForegroundColor Red
        throw "Visual Studio Code is not installed, please install it and try again."
    }

    & $codeInsiders $Folder

}
function Initialize-Typescript {
    [CmdletBinding()]
    param (
        [string] $Folder
    )

    process {
        $CURRENT_DIR = Join-Path -Path (Get-Location) -ChildPath $Folder

        if ((Test-Path -Path $CURRENT_DIR) -eq $false) {
            Write-Host "[x] Creating project folder." -ForegroundColor Green
            New-Item -Path $CURRENT_DIR -Force -ItemType Directory | Out-Null
            if ($? -eq $false) {
                Write-Host "[x] Failed to create project folder, Aborting!" -ForegroundColor Red
                return
            }
        }

        Set-Location $CURRENT_DIR

        Write-Host "[x] Initializing pnpm project." -ForegroundColor Green
        pnpm init | Out-Null

        Write-Host "[x] Installing typescript packages." -ForegroundColor Green
        pnpm add @types/node ts-node typescript -D  | Out-Null

        Write-Host "[x] Creating default typescript config." -ForegroundColor Green
        Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "tsconfig.json") -Destination . -Force -Recurse | Out-Null

        Write-Host "[x] Creating VSCode typescript debugger config." -ForegroundColor Green
        New-Item -Path .vscode -Force -ItemType Directory | Out-Null
        Copy-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath "vs-config.json") -Destination ".vscode/launch.json" -Force -Recurse | Out-Null

        Write-Host "[x] Creating index.ts" -ForegroundColor Green
        New-Item -Name src/index.ts -ItemType File -Force | Out-Null

        New-NPMScript -ScriptName "start" -ScriptCommand "ts-node src/index.ts" -PackageJsonPath "package.json"

        Start-VisualStudioCode -Folder $CURRENT_DIR
    }
}

Export-ModuleMember -Function Initialize-Typescript