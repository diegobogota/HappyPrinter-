# Publicar HappyPrint en GitHub — Guía para el desarrollador

Esta guía es para ti (no forma parte de la app). Sigue estos pasos para crear
el repo y que los usuarios se puedan descargar la app.

## 1. Crear el repo en GitHub

1. Entra a https://github.com/new
2. **Repository name:** `HappyPrint`
3. **Description:** `Fixer de impresoras Epson para Windows 11 — detecta y repara impresoras borradas o que dejaron de funcionar`
4. Visibilidad: **Public** (para que los usuarios puedan descargarlo)
5. NO marques "Add a README" (ya tenemos uno)
6. Clic en **Create repository**

## 2. Subir el proyecto desde la terminal

Abre la terminal en la carpeta del proyecto y ejecuta:

```bash
git init
git add .
git commit -m "HappyPrint - Fixer Epson Printer: version inicial"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/HappyPrint.git
git push -u origin main
```

> Reemplaza `TU-USUARIO` por tu usuario de GitHub.

## 3. Crear un Release (recomendado)

Al crear un tag `v*` y publicarlo, GitHub Actions compila automáticamente el
`.exe` y el instalador, y los adjunta al Release. No necesitas compilar nada
en tu Mac.

```bash
git tag v1.0.0
git push origin v1.0.0
```

O desde la web del repo: **Releases** → **Draft a new release** →
**Choose a tag** → escribe `v1.0.0` → **Publish release**.

Después de 2-5 minutos, el Release tendrá estos archivos listos para usuarios:

- `HappyPrint-Setup.exe` — instalador con asistente (recomendado para usuarios)
- `HappyPrint.exe` — portable, sin instalación

También puedes lanzar el build manualmente: pestaña **Actions** →
**Build Windows EXE e Instalador** → **Run workflow**.

## 4. Verificar

- Abre el repo en una ventana de incognito y comprueba que el README se ve bien
- Descarga el ZIP en una PC con Windows 11 y prueba la app de punta a punta
- Verifica que el aviso UAC aparece y que el modo reparacion funciona

## Notas

- El nombre visible del repo puede ser `HappyPrint` aunque la carpeta local se llame distinto.
- Si quieres que el repo se llame distinto (por ejemplo `happyprint-fixer`), solo cambia el nombre al crearlo y ajusta la URL en el README.
