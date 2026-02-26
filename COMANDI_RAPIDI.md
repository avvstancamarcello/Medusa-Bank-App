# ⚡ COMANDI RAPIDI - CHEAT SHEET

## 🔧 **WORKFLOW QUOTIDIANO**

### **Modifica Veloce (NO Cifratura)**
```powershell
# 1. Modifica JSON
code "c:\Users\Utente\BancheEuropa\financial_authorities_database.json"

# 2. Deploy immediato
cd "c:\Users\Utente\Financial-Authority-Database"
Copy-Item "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" . -Force
Remove-Item db.enc -ErrorAction SilentlyContinue
git add financial_authorities_database.json
git commit -m "Fix: [descrizione]"
git push
```

---

### **Deploy con Cifratura**
```powershell
# 1. Modifica JSON
code "c:\Users\Utente\BancheEuropa\financial_authorities_database.json"

# 2. Cifra
cd "c:\Users\Utente\BancheEuropa"
.\cifra_database.ps1

# 3. Deploy
cd "c:\Users\Utente\Financial-Authority-Database"
git add db.enc financial_authorities_database.json
git commit -m "Update: [descrizione] + cifratura"
git push
```

---

## 🔐 **CIFRATURA**

### **Cifra Database**
```powershell
cd "c:\Users\Utente\BancheEuropa"
.\cifra_database.ps1
```

### **Verifica Cifratura**
```powershell
cd "c:\Users\Utente\BancheEuropa"
.\decifra_database.ps1
# Controlla db_decrypted.json
Remove-Item db_decrypted.json
```

### **Cifra Manuale (se script non disponibile)**
```powershell
cd "c:\Users\Utente\BancheEuropa"
$data = Get-Content 'financial_authorities_database.json' -Raw
$key = 'MarcelloStancaFlorenceIT2026'
$result = ''
for ($i = 0; $i -lt $data.Length; $i++) {
    $result += [char]([int]$data[$i] -bxor [int]$key[$i % $key.Length])
}
$bytes = [System.Text.Encoding]::UTF8.GetBytes($result)
$encoded = [Convert]::ToBase64String($bytes)
Set-Content 'db.enc' $encoded
Copy-Item db.enc "c:\Users\Utente\Financial-Authority-Database\"
```

---

## ✅ **VALIDAZIONE JSON**

### **Test Validità**
```powershell
cd "c:\Users\Utente\BancheEuropa"
try {
    $json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
    $count = ($json.PSObject.Properties | Where-Object { $_.Value.country_name }).Count
    Write-Host "✅ JSON valido - $count paesi" -ForegroundColor Green
} catch {
    Write-Host "❌ ERRORE: $($_.Exception.Message)" -ForegroundColor Red
}
```

### **Conta Paesi**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
($json.PSObject.Properties | Where-Object { $_.Value.country_name }).Count
```

### **Lista Tutti i Paesi**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
$json.PSObject.Properties | Where-Object { $_.Value.country_name } | 
    Select-Object -ExpandProperty Name | Sort-Object
```

---

## 📂 **FILE MANAGEMENT**

### **Copia JSON da Dev a Prod**
```powershell
Copy-Item "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" `
          "c:\Users\Utente\Financial-Authority-Database\" -Force
```

### **Copia db.enc da Dev a Prod**
```powershell
Copy-Item "c:\Users\Utente\BancheEuropa\db.enc" `
          "c:\Users\Utente\Financial-Authority-Database\" -Force
```

### **Backup Database**
```powershell
$date = Get-Date -Format "yyyy-MM-dd_HHmm"
Copy-Item "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" `
          "c:\Users\Utente\BancheEuropa\backup_$date.json"
```

---

## 🌐 **GIT OPERATIONS**

### **Status Rapido**
```powershell
cd "c:\Users\Utente\Financial-Authority-Database"
git status -s
```

### **Commit Rapido**
```powershell
git add .
git commit -m "Update: [descrizione]"
git push
```

### **Commit Solo JSON**
```powershell
git add financial_authorities_database.json
git commit -m "Fix: [descrizione]"
git push
```

### **Commit Solo Cifratura**
```powershell
git add db.enc
git commit -m "Database cifrato aggiornato"
git push
```

### **Annulla Ultimo Commit (locale)**
```powershell
git reset HEAD~1
```

### **Vedi Ultimi 5 Commit**
```powershell
git log --oneline -5
```

---

## 🔍 **RICERCA NEL DATABASE**

### **Cerca Paese per Nome**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
$json.Italy
```

### **Cerca Paesi UE**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
$json.PSObject.Properties | Where-Object { $_.Value.isEU -eq $true } | 
    Select-Object Name, @{N='Country';E={$_.Value.country_name}}
```

### **Cerca per Livello Protezione**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
$json.PSObject.Properties | Where-Object { $_.Value.protectionLevel -eq 'altissimo' } | 
    Select-Object @{N='Country';E={$_.Value.country_name}}
```

### **Lista Email Autorità**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json
$json.PSObject.Properties | Where-Object { $_.Value.country_name } | 
    Select-Object @{N='Paese';E={$_.Value.country_name}}, 
                  @{N='Email';E={$_.Value.financial_authority.authorityEmail}}
```

---

## 📊 **STATISTICHE DATABASE**

### **Conteggi Rapidi**
```powershell
$json = Get-Content 'financial_authorities_database.json' -Raw | ConvertFrom-Json

$total = ($json.PSObject.Properties | Where-Object { $_.Value.country_name }).Count
$eu = ($json.PSObject.Properties | Where-Object { $_.Value.isEU -eq $true }).Count
$altissimo = ($json.PSObject.Properties | Where-Object { $_.Value.protectionLevel -eq 'altissimo' }).Count

Write-Host "📊 STATISTICHE DATABASE" -ForegroundColor Cyan
Write-Host "   • Paesi totali: $total"
Write-Host "   • Paesi UE: $eu"
Write-Host "   • Protezione altissima: $altissimo"
Write-Host "   • Paesi non-UE: $($total - $eu)"
```

### **Dimensione File**
```powershell
$jsonSize = (Get-Item 'financial_authorities_database.json').Length
$encSize = (Get-Item 'db.enc' -ErrorAction SilentlyContinue).Length

Write-Host "📦 DIMENSIONI FILE" -ForegroundColor Cyan
Write-Host "   • JSON: $([Math]::Round($jsonSize/1KB, 2)) KB"
if ($encSize) {
    Write-Host "   • Cifrato: $([Math]::Round($encSize/1KB, 2)) KB"
    Write-Host "   • Overhead: $([Math]::Round(($encSize-$jsonSize)/$jsonSize*100, 2))%"
}
```

---

## 🧪 **TEST & VERIFICA**

### **Test Caricamento Sito Locale**
```powershell
cd "c:\Users\Utente\Financial-Authority-Database"
python -m http.server 8000
# Apri: http://localhost:8000
```

### **Verifica Link GitHub Pages**
```powershell
Start-Process "https://avvstancamarcello.github.io/Financial-Authority-Database/"
```

### **Verifica Sitemap**
```powershell
Start-Process "https://avvstancamarcello.github.io/Financial-Authority-Database/sitemap.xml"
```

### **Verifica Robots.txt**
```powershell
Start-Process "https://avvstancamarcello.github.io/Financial-Authority-Database/robots.txt"
```

---

## 🛠️ **MANUTENZIONE**

### **Pulisci File Temporanei**
```powershell
cd "c:\Users\Utente\BancheEuropa"
Remove-Item db_decrypted.json -ErrorAction SilentlyContinue
Write-Host "✅ File temporanei rimossi"
```

### **Sincronizza Dev → Prod**
```powershell
# Copia tutti i file importanti
Copy-Item "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" `
          "c:\Users\Utente\Financial-Authority-Database\" -Force
Copy-Item "c:\Users\Utente\BancheEuropa\db.enc" `
          "c:\Users\Utente\Financial-Authority-Database\" -Force
Copy-Item "c:\Users\Utente\BancheEuropa\index.html" `
          "c:\Users\Utente\Financial-Authority-Database\" -Force
```

### **Verifica Integrità Repository**
```powershell
cd "c:\Users\Utente\Financial-Authority-Database"
git fsck
```

---

## 📝 **TEMPLATE COMMIT MESSAGES**

```
Fix: Corretto link homepage [paese]
Update: Aggiornata email [autorità]
Add: Aggiunto [paese] - [n] paesi totali
Batch: Aggiornati [n] paesi [area geografica]
Security: Database cifrato aggiornato
SEO: Ottimizzazioni meta tags
Feature: Aggiunto supporto [funzionalità]
Docs: Aggiornata documentazione
```

---

## 🔑 **VARIABILI IMPORTANTI**

```powershell
# Chiave cifratura
$COPYRIGHT_KEY = 'MarcelloStancaFlorenceIT2026'

# Path file
$DEV_JSON = "c:\Users\Utente\BancheEuropa\financial_authorities_database.json"
$PROD_JSON = "c:\Users\Utente\Financial-Authority-Database\financial_authorities_database.json"
$DEV_ENC = "c:\Users\Utente\BancheEuropa\db.enc"
$PROD_ENC = "c:\Users\Utente\Financial-Authority-Database\db.enc"

# URL
$LIVE_SITE = "https://avvstancamarcello.github.io/Financial-Authority-Database/"
$GITHUB_REPO = "https://github.com/avvstancamarcello/Financial-Authority-Database"
```

---

## 🚀 **ONE-LINER UTILI**

### **Deploy Completo Veloce**
```powershell
cd "c:\Users\Utente\BancheEuropa"; .\cifra_database.ps1; cd "c:\Users\Utente\Financial-Authority-Database"; git add db.enc financial_authorities_database.json; git commit -m "Database update"; git push
```

### **Conta + Valida + Deploy**
```powershell
$json = Get-Content "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" -Raw | ConvertFrom-Json; $count = ($json.PSObject.Properties | Where-Object {$_.Value.country_name}).Count; Write-Host "✅ $count paesi validati"; cd "c:\Users\Utente\Financial-Authority-Database"; Copy-Item "c:\Users\Utente\BancheEuropa\financial_authorities_database.json" . -Force; git add financial_authorities_database.json; git commit -m "Update: $count paesi"; git push
```

---

**© 2026 Avvocato Marcello Stanca - Firenze, Italy**

💡 **Tip:** Salva questo file come preferito per accesso rapido!
