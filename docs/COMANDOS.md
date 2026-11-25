# 🖨️ HappyPrint — Comandos para Windows 11

Guía rápida para usuarios no técnicos. Copia **una línea a la vez** y presiona **Enter** después de cada una.

---

## ✅ Instalación (2 comandos)

### Comando 1 — Descargar el programa

```powershell
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/diegobogota/HappyPrinter-/main/src/HappyPrint-Fixer.ps1' -OutFile "$env:TEMP\HappyPrint-Fixer.ps1"
```

### Comando 2 — Ejecutar el programa (abre el UAC)

```powershell
Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File',"$env:TEMP\HappyPrint-Fixer.ps1"
```

Después: acepta el UAC (**Sí**) y la ventana de HappyPrint se abrirá sola.

---

## 🆘 Comandos de diagnóstico

### Ver el log de diagnóstico

```powershell
notepad "$env:TEMP\HappyPrint-Fixer.log"
```

### Verificar que el script se descargó

```powershell
dir "$env:TEMP\HappyPrint-Fixer.ps1"
```

### Activar TLS (si la descarga falla)

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

### Ejecutar con la consola abierta (ver el error real)

En **Terminal (Administrador)** (Win + X):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -NoExit -File "$env:TEMP\HappyPrint-Fixer.ps1"
```

### Limpiar la terminal (si se mezclaron líneas)

```powershell
cls
```

---

## 📋 Método alternativo — Un solo bloque (3 líneas juntas)

Si prefieres pegar todo de una vez (solo si el método de arriba falla):

```powershell
$dest = "$env:TEMP\HappyPrint-Fixer.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/diegobogota/HappyPrinter-/main/src/HappyPrint-Fixer.ps1' -OutFile $dest
Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-NoExit','-File', $dest
```

> ⚠️ Si al pegar sale "no se encontró ningún parámetro de posición", usa el método de 2 comandos de arriba (uno por línea).

---

## 🆘 Errores comunes

| Lo que ves | Solución |
|---|---|
| Rojo en la descarga | Pega primero: `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12` y repite |
| "Parámetro de posición" | `cls` y pega una línea a la vez |
| Ventana parpadea | `notepad "$env:TEMP\HappyPrint-Fixer.log"` y manda el contenido |
| SmartScreen azul | **Más información** → **Ejecutar de todas formas** |
| Nada abre | Win + X → Terminal (Administrador) → comando de diagnóstico avanzado |

---

## 📞 Soporte

- Repositorio: **https://github.com/diegobogota/HappyPrinter-**
- Descargas: **https://github.com/diegobogota/HappyPrinter-/releases**
- Autoría: **www.aleluia.tech**
