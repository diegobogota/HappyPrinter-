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

Para que los usuarios descarguen un ZIP limpio con un solo clic:

1. En el repo: **Releases** → **Create a new release**
2. **Tag:** `v1.0.0`
3. **Title:** `HappyPrint v1.0.0`
4. **Description:**
   ```
   Primera version publica.
   - Deteccion completa de impresoras Epson (USB, red, rastros)
   - Modo reparacion con un clic (puertos huerfanos, drivers residuales, Spooler)
   - Interfaz estilo macOS para Windows 11
   ```
5. Opcional: adjunta un ZIP con solo `src/HappyPrint-Fixer.ps1` + `assets/`
6. Clic en **Publish release**

## 4. Verificar

- Abre el repo en una ventana de incognito y comprueba que el README se ve bien
- Descarga el ZIP en una PC con Windows 11 y prueba la app de punta a punta
- Verifica que el aviso UAC aparece y que el modo reparacion funciona

## Notas

- El nombre visible del repo puede ser `HappyPrint` aunque la carpeta local se llame distinto.
- Si quieres que el repo se llame distinto (por ejemplo `happyprint-fixer`), solo cambia el nombre al crearlo y ajusta la URL en el README.
