# Epson EcoTank L14150 — Detector de Impresoras para Windows 11

## Objetivo
Crear un programa para Windows 11 que ayude a detectar fácilmente las impresoras
Epson EcoTank L14150 conectadas al equipo (USB o red) y guíe al usuario si no
se detecta ninguna.

## Alcance
- Detectar impresoras Epson L14150 por:
  - USB (WMI / PnP)
  - Red (mDNS/Bonjour, WSD, SNMP opcional)
- Mostrar estado: detectada / no detectada, tipo de conexión, IP si aplica.
- Acciones útiles: abrir cola de impresión, abrir configuración de Windows,
  reintentar detección, copiar IP.
- Idioma: español (interfaz).

## Stack propuesto
- Lenguaje: C# (.NET 8) con WPF o WinForms — integración nativa con Windows.
- Alternativa ligera: PowerShell + WPF (sin compilación, más simple).
- Detección:
  - `System.Printing` / WMI (`Win32_Printer`, `Win32_PnPEntity`)
  - mDNS: consulta `_ipp._tcp.local` / `_printer._tcp.local`
  - SNMP (opcional): OID de sysDescr para identificar modelo Epson.

## Estructura del proyecto
```
EpsonL14150-Detector/
├── src/                  # Código fuente
├── docs/                 # Documentación y plan
├── tests/                # Pruebas
└── README.md
```

## Fases
1. **Investigación** — confirmar identificadores del modelo (nombre PnP, IDs USB
   VID/PID de Epson, cadenas mDNS que emite la L14150).
2. **Prototipo de detección** — script/listado de impresoras instaladas y
   filtrado por "L14150" / "Epson".
3. **Detección de red** — escaneo mDNS y (opcional) SNMP en la subred local.
4. **UI** — ventana simple con estado y botones de acción.
5. **Empaquetado** — instalador MSI o exe autocontenido (dotnet publish).
6. **Pruebas en Windows 11** — validar con y sin impresora conectada.

## Notas
- El desarrollo se hace en macOS; la compilación para Windows se puede hacer
  con .NET 8 (cross-platform) y probar en una máquina virtual o PC con Windows 11.
- La detección USB requiere pruebas reales en Windows (WMI no funciona en macOS).
