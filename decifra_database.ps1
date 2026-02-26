# ===================================================
# SCRIPT DECIFRATURA DATABASE (per verifica)
# © 2026 Avvocato Marcello Stanca - Firenze, Italy
# ===================================================
#
# UTILIZZO:
#   Esegui: .\decifra_database.ps1
#   Output: db_decrypted.json (per controllo)
#
# ===================================================

Write-Host "`n🔓 DECIFRATURA DATABASE (Verifica)" -ForegroundColor Cyan
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host ""

# Verifica esistenza db.enc
if (-not (Test-Path "db.enc")) {
    Write-Host "❌ ERRORE: File db.enc non trovato!" -ForegroundColor Red
    Write-Host "   Esegui prima: .\cifra_database.ps1`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n📄 Lettura file cifrato db.enc..." -ForegroundColor Yellow
$encoded = Get-Content 'db.enc' -Raw
$encSize = $encoded.Length

Write-Host "✅ File caricato: $encSize caratteri Base64" -ForegroundColor Green

# Chiave proprietaria
$key = 'MarcelloStancaFlorenceIT2026'

Write-Host "`n📦 Decodifica Base64..." -ForegroundColor Yellow
$bytes = [Convert]::FromBase64String($encoded)
$encrypted = [System.Text.Encoding]::UTF8.GetString($bytes)

Write-Host "✅ Decodifica completata" -ForegroundColor Green

Write-Host "`n🔑 Applicazione decifratura XOR..." -ForegroundColor Yellow
$result = ''
$progressInterval = [Math]::Max(1, [Math]::Floor($encrypted.Length / 100))

for ($i = 0; $i -lt $encrypted.Length; $i++) {
    $result += [char]([int]$encrypted[$i] -bxor [int]$key[$i % $key.Length])
    
    if ($i % $progressInterval -eq 0) {
        $percent = [Math]::Floor(($i / $encrypted.Length) * 100)
        Write-Progress -Activity "Decifratura XOR" -Status "$percent% completato" -PercentComplete $percent
    }
}
Write-Progress -Activity "Decifratura XOR" -Completed

Write-Host "✅ Decifratura XOR completata" -ForegroundColor Green

# Validazione JSON
Write-Host "`n🔍 Validazione JSON..." -ForegroundColor Yellow
try {
    $jsonTest = $result | ConvertFrom-Json
    $countryCount = ($jsonTest.PSObject.Properties | Where-Object { $_.Value.country_name }).Count
    Write-Host "✅ JSON valido: $countryCount paesi rilevati" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRORE: JSON non valido dopo decifratura!" -ForegroundColor Red
    Write-Host "   Possibile chiave errata o file corrotto`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n💾 Salvataggio db_decrypted.json..." -ForegroundColor Yellow
Set-Content 'db_decrypted.json' $result

Write-Host "✅ File salvato per verifica" -ForegroundColor Green

# Confronto con originale
if (Test-Path "financial_authorities_database.json") {
    Write-Host "`n🔍 Confronto con file originale..." -ForegroundColor Yellow
    $original = Get-Content 'financial_authorities_database.json' -Raw
    
    if ($original -eq $result) {
        Write-Host "✅ PERFETTO! File decifrato identico all'originale" -ForegroundColor Green
    } else {
        Write-Host "⚠️  ATTENZIONE: File decifrato differisce dall'originale" -ForegroundColor Yellow
        Write-Host "   Possibili cause: JSON modificato dopo cifratura" -ForegroundColor Gray
    }
}

Write-Host "`n" -NoNewline
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host ""
Write-Host "🎉 DECIFRATURA COMPLETATA!" -ForegroundColor Green
Write-Host "   File verifica: db_decrypted.json"
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host "`n"

Write-Host "⚠️  RICORDA: Elimina db_decrypted.json dopo la verifica" -ForegroundColor Yellow
Write-Host "   Comando: Remove-Item db_decrypted.json`n"
