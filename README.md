# 🖨️ HappyPrint - Fixer Epson Printer

Programa gratuito para **Windows 11** que detecta y **repara** problemas de
impresoras **Epson EcoTank** (probado con la **L14150**), tanto activas como
impresoras que fueron instaladas antes, se borraron o dejaron de funcionar.

## 📥 Descarga

Tienes 3 formas de instalar la app:

### Opción 0 — Un solo comando (la más rápida)

> ✅ Descarga el script directamente de la rama `main` y lo ejecuta.
> Sin ZIP, sin EXE, sin avisos de antivirus.

Abre **PowerShell** y pega:

```powershell
$dest = "$env:TEMP\HappyPrint-Fixer.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/diegobogota/HappyPrinter-/main/src/HappyPrint-Fixer.ps1' -OutFile $dest
Start-Process powershell -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File', $dest) -Verb RunAs
```

Se abrirá el aviso de UAC: acepta y la app arranca con permisos de reparación.

> 💡 El script se descarga siempre de la rama `main`, así que obtienes la
> última versión con todas las funciones sin esperar un Release.

### Opción 1 — Script PowerShell (ZIP del repo)

> ✅ Este método **no dispara antivirus** ni SmartScreen.

1. Entra a la página del repo en GitHub: **https://github.com/diegobogota/HappyPrinter-**
2. Clic en el botón verde **`<> Code`** → **Download ZIP**
3. Descomprime el ZIP en cualquier carpeta
4. Abre la carpeta `src/` y haz clic derecho sobre `HappyPrint-Fixer.ps1` → **Ejecutar con PowerShell**
5. Acepta el aviso de UAC (es necesario para poder reparar)

> 💡 Si Windows bloquea la ejecución del script, abre PowerShell y ejecuta una vez:
>
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

### Opción 2 — Instalador

1. Entra a **https://github.com/diegobogota/HappyPrinter-/releases**
2. Descarga **`HappyPrint-Setup.exe`** (instalador con asistente)
3. Ejecuta el instalador: crea accesos directos y deja la app lista en `C:\Program Files\HappyPrint`

### Opción 3 — EXE portable (sin instalación)

1. Entra a **https://github.com/diegobogota/HappyPrinter-/releases**
2. Descarga **`HappyPrint.exe`** (un solo archivo, no requiere instalación)
3. Haz doble clic para ejecutarlo

> ⚠️ **Aviso sobre el EXE:** algunos antivirus pueden marcar el `.exe` como
> sospechoso. Es un **falso positivo**: el EXE es un script PowerShell
> empaquetado, y los antivirus son sensibles a esa técnica. Es 100% seguro:
> el código es público y auditable en este repositorio.
>
> Si tu antivirus lo bloquea:
> - **Windows Defender:** clic en el aviso → **Más información** → **Ejecutar de todas formas**
> - **Otro antivirus:** agrega una excepción para el archivo, o usa la Opción 1 (script), que no tiene este problema

## Autoría

> **www.aleluia.tech** — Todos los derechos reservados.

## ✨ Características

- ✅ Detecta impresoras Epson instaladas en Windows (USB o red)
- 🔍 Detecta **rastros de impresoras borradas o que dejaron de andar**:
  - Puertos de impresión huérfanos (quedaron sin impresora)
  - Drivers Epson residuales aunque la impresora ya no exista
  - Historial USB (dispositivos Epson conectados alguna vez, incluso desconectados)
  - Eventos de Windows sobre instalación/eliminación de impresoras
- 🌐 Escaneo rápido de la red local (tabla ARP + puerto 9100) buscando la impresora viva
- 🛠️ **Modo reparación con un clic** (admin):
  - Elimina puertos huérfanos
  - Desinstala drivers Epson residuales (solo los que no usan impresoras activas)
  - Inicia el Spooler si está detenido
- 🖥️ Interfaz gráfica (WPF) con estilo similar a las apps de macOS:
  esquinas redondeadas, semáforos de ventana, tarjeta de estado con punto de color
- ⚡ Sencillo y rápido: un solo archivo `.ps1`, sin dependencias, sin instalación

## Requisitos

- Windows 11 (también funciona en Windows 10)
- Windows PowerShell 5.1 (incluido por defecto, no requiere instalación)
- Cuenta con permisos de administrador (para el modo reparación)

## Estructura del proyecto

```
HappyPrint/
├── src/
│   └── HappyPrint-Fixer.ps1       # Aplicación principal (PowerShell + WPF)
├── assets/
│   ├── PrintHappy.ico             # Icono de la app (Windows 11)
│   └── PrintHappy-256.png         # Icono en PNG 256x256
├── docs/
│   └── PLAN.md                    # Plan del proyecto
├── PrintHappy.avif                # Imagen original del icono
└── README.md
```

## Qué revisa el diagnóstico

| Sección | Descripción |
|---|---|
| Servicio Spooler | Verifica que el servicio de impresión esté en ejecución |
| Impresoras instaladas | Lista impresoras Epson activas y marca la L14150 |
| Puertos huérfanos | Puertos que quedaron de impresoras borradas |
| Drivers Epson | Drivers residuales aunque la impresora no exista |
| Historial USB | Dispositivos Epson conectados alguna vez (presentes o no) |
| Eventos de Windows | Historial de instalación/eliminación de impresoras |
| Escaneo de red | Dispositivos con puerto de impresión (9100) abiertos en la red local |

## Acciones disponibles

- **Escanear** — repite el diagnóstico completo
- **Reparar** — limpia automáticamente (la app se eleva sola con UAC):
  - Elimina puertos de impresión huérfanos
  - Desinstala drivers Epson residuales (sin impresora asociada)
  - Inicia el Spooler si está detenido
- **Config.** — abre la configuración de impresoras de Windows
- **Spooler** — reinicia el servicio de impresión (útil cuando la cola se cuelga)

## Seguridad del modo reparación

- Solo elimina drivers **sin impresora asociada** — los drivers de impresoras activas no se tocan
- Solo elimina puertos que **ninguna impresora usa**
- Si no hay nada que reparar, lo informa en lugar de forzar cambios

## Notas

- El desarrollo se realiza en macOS; la ejecución y pruebas se hacen en Windows 11.
- Al abrir la app, Windows pedirá confirmación de administrador (UAC): es necesario para las funciones de reparación.
- Driver oficial de Epson: https://epson.com/soporte

---

© 2026 **www.aleluia.tech** — Todos los derechos reservados.
