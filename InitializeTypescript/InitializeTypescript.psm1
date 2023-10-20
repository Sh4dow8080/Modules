#requires -Version 7

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

        Write-Host "[x] Opening project VSCode." -ForegroundColor Green
        code $CURRENT_DIR
    }
}

Export-ModuleMember -Function Initialize-Typescript