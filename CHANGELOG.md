# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el proyecto sigue [Versionado Semántico](https://semver.org/lang/es/).

## [No publicado]

### Planeado

- Soporte para más modelos de impresoras Epson (no solo L14150)
- Detección mDNS/Bonjour para impresoras de red
- Firma digital del instalador (elimina el aviso de SmartScreen)

## [1.0.0] - 2026-11-24

### Agregado

- Detección completa de impresoras Epson EcoTank (probado con L14150):
  - Impresoras activas instaladas (USB o red)
  - Puertos de impresión huérfanos (rastros de impresoras borradas)
  - Drivers Epson residuales aunque la impresora ya no exista
  - Historial USB de dispositivos Epson (presentes o no)
  - Eventos de Windows sobre instalación/eliminación de impresoras
  - Escaneo de red local (tabla ARP + puerto 9100)
- Modo reparación con un clic (requiere admin):
  - Elimina puertos de impresión huérfanos
  - Desinstala drivers Epson residuales (solo los sin impresora asociada)
  - Inicia el Spooler si está detenido
- Elevación automática a administrador (UAC) al abrir la app
- Interfaz WPF estilo macOS: esquinas redondeadas, semáforos de ventana,
  tarjeta de estado con punto de color
- Icono PrintHappy embebido en la app (base64) y en el EXE/instalador
- Build automático con GitHub Actions: genera `HappyPrint.exe` portable y
  `HappyPrint-Setup.exe` (instalador Inno Setup) en cada tag `v*`

### Notas

- El EXE no está firmado digitalmente: Windows SmartScreen mostrará un aviso
  la primera vez ("Más información" → "Ejecutar de todas formas").
- El script `.ps1` siempre funciona como respaldo si el EXE falla.

[1.0.0]: https://github.com/diegobogota/HappyPrinter-/releases/tag/v1.0.0
