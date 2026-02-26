# ===================================================
# SCRIPT CIFRATURA DATABASE
# © 2026 Avvocato Marcello Stanca - Firenze, Italy
# ===================================================
#
# UTILIZZO:
#   1. Modifica financial_authorities_database.json
#   2. Esegui: .\cifra_database.ps1
#   3. File db.enc creato automaticamente
#
# ===================================================

Write-Host "`n🔐 CIFRATURA DATABASE FINANCIAL AUTHORITIES" -ForegroundColor Cyan
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host ""

# Verifica esistenza JSON
if (-not (Test-Path "financial_authorities_database.json")) {
    Write-Host "❌ ERRORE: File financial_authorities_database.json non trovato!" -ForegroundColor Red
    exit 1
}

Write-Host "`n📄 Lettura file JSON..." -ForegroundColor Yellow
$data = Get-Content 'financial_authorities_database.json' -Raw
$jsonSize = $data.Length

Write-Host "✅ JSON caricato: $jsonSize caratteri" -ForegroundColor Green

# Chiave proprietaria
$key = 'MarcelloStancaFlorenceIT2026'

Write-Host "`n🔑 Applicazione cifratura XOR..." -ForegroundColor Yellow
$result = ''
$progressInterval = [Math]::Max(1, [Math]::Floor($data.Length / 100))

for ($i = 0; $i -lt $data.Length; $i++) {
    $result += [char]([int]$data[$i] -bxor [int]$key[$i % $key.Length])
    
    # Progress bar ogni 1%
    if ($i % $progressInterval -eq 0) {
        $percent = [Math]::Floor(($i / $data.Length) * 100)
        Write-Progress -Activity "Cifratura XOR" -Status "$percent% completato" -PercentComplete $percent
    }
}
Write-Progress -Activity "Cifratura XOR" -Completed

Write-Host "✅ Cifratura XOR completata" -ForegroundColor Green

Write-Host "`n📦 Encoding Base64..." -ForegroundColor Yellow
$bytes = [System.Text.Encoding]::UTF8.GetBytes($result)
$encoded = [Convert]::ToBase64String($bytes)

Write-Host "✅ Encoding completato" -ForegroundColor Green

Write-Host "`n💾 Salvataggio db.enc..." -ForegroundColor Yellow
Set-Content 'db.enc' $encoded

$encSize = (Get-Item 'db.enc').Length

Write-Host "✅ File db.enc creato: $encSize bytes" -ForegroundColor Green

# Statistiche
Write-Host "`n" -NoNewline
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host ""
Write-Host "📊 STATISTICHE:" -ForegroundColor Cyan
Write-Host "   • File originale (JSON): $jsonSize caratteri"
Write-Host "   • File cifrato (db.enc): $encSize bytes"
Write-Host "   • Rapporto compressione: $([Math]::Round($encSize / $jsonSize * 100, 2))%"
Write-Host "   • Chiave utilizzata: MarcelloStancaFlorenceIT2026"
Write-Host "=" -NoNewline; for ($i=0; $i -lt 50; $i++) { Write-Host "=" -NoNewline }; Write-Host "`n"

# Copia automatica nella repo deployment
$deployPath = "c:\Users\Utente\Financial-Authority-Database\db.enc"
if (Test-Path "c:\Users\Utente\Financial-Authority-Database") {
    Write-Host "📤 Copia in directory deployment..." -ForegroundColor Yellow
    Copy-Item 'db.enc' $deployPath -Force
    Write-Host "✅ File copiato in: $deployPath" -ForegroundColor Green
} else {
    Write-Host "⚠️  Directory deployment non trovata, copia manuale necessaria" -ForegroundColor Yellow
}

Write-Host "`n🎉 CIFRATURA COMPLETATA CON SUCCESSO!" -ForegroundColor Green
Write-Host "`n📋 PROSSIMI PASSI:" -ForegroundColor Cyan
Write-Host "   1. cd c:\Users\Utente\Financial-Authority-Database"
Write-Host "   2. git add db.enc financial_authorities_database.json"
Write-Host "   3. git commit -m 'Database aggiornato'"
Write-Host "   4. git push`n"
