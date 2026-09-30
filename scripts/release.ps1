# Publica uma nova versão do app no GitHub (Releases), com o APK anexado.
# O botão "Buscar atualização" do app consulta essas Releases.
#
# Uso (na pasta do projeto):
#   1. Aumente a versão em pubspec.yaml (ex: version: 1.0.1+2)
#   2. powershell -ExecutionPolicy Bypass -File scripts\release.ps1 -Notes "O que mudou"

param([string]$Notes = "")

# Sem 'Stop': no PowerShell 5.1 ele trata qualquer saída de erro do gh/flutter como falha.
# Os erros são verificados pelo $LASTEXITCODE.
Set-Location (Split-Path $PSScriptRoot -Parent)

$version = (Select-String -Path pubspec.yaml -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)').Matches[0].Groups[1].Value
$tag = "v$version"
Write-Host "Versão: $version" -ForegroundColor Cyan

gh release view $tag *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "A versão $tag já foi publicada. Aumente 'version' no pubspec.yaml." -ForegroundColor Red
    exit 1
}

flutter build apk --release
if ($LASTEXITCODE -ne 0) { Write-Host "Falha no build." -ForegroundColor Red; exit 1 }

$apk = "build\receitas-da-anna-$version.apk"
Copy-Item build\app\outputs\flutter-apk\app-release.apk $apk -Force

git push
if ($LASTEXITCODE -ne 0) { Write-Host "Falha no git push." -ForegroundColor Red; exit 1 }

if ($Notes) {
    gh release create $tag $apk --title "Receitas da Anna $version" --notes $Notes
} else {
    gh release create $tag $apk --title "Receitas da Anna $version" --generate-notes
}
if ($LASTEXITCODE -ne 0) { Write-Host "Falha ao criar a release." -ForegroundColor Red; exit 1 }

Write-Host "Publicado! O app vai encontrar a versão $version em 'Buscar atualização'." -ForegroundColor Green
