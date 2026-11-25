<#
.SYNOPSIS
    HappyPrint - Fixer Epson Printer - Windows 11 - Interfaz estilo macOS.
.DESCRIPTION
    Detecta impresoras Epson activas y rastros de impresoras borradas o que
    dejaron de funcionar: puertos huerfanos, drivers residuales, historial USB,
    eventos de Windows y escaneo de la red local. Incluye modo reparacion
    (admin) para limpiar puertos y drivers residuales con un clic.
.USAGE
    Clic derecho sobre el archivo -> "Ejecutar con PowerShell"
.NOTES
    Windows PowerShell 5.1 (incluido en Windows 11). La app se eleva sola a
    administrador (UAC) para poder reparar.
    Autoria: www.aleluia.tech
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'SilentlyContinue'

# ------------------------------------- Elevacion automatica a administrador
# Las funciones de reparacion (limpiar puertos/drivers) requieren admin.
# Si no estamos elevados, relanzamos el script con UAC.
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath 'powershell.exe' `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath)) `
        -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$script:Modelo   = 'L14150'
$script:VidEpson = 'VID_04B8'

# ------------------------------------------------------------------ XAML
$xamlText = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Width="560" Height="720"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        FontFamily="Segoe UI" ResizeMode="CanMinimize">
  <Window.Resources>
    <Style TargetType="Button">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border CornerRadius="8" Background="{TemplateBinding Background}" Padding="10,9">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter Property="Opacity" Value="0.85"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter Property="Opacity" Value="0.7"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Setter Property="FontSize" Value="12"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="BorderThickness" Value="0"/>
    </Style>
  </Window.Resources>
  <Border CornerRadius="12" Background="#F2F2F5" BorderBrush="#D8D8DE" BorderThickness="1" Margin="8">
    <Border.Effect>
      <DropShadowEffect BlurRadius="14" ShadowDepth="1" Opacity="0.25"/>
    </Border.Effect>
    <Grid>
      <Grid.RowDefinitions>
        <RowDefinition Height="46"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="34"/>
      </Grid.RowDefinitions>

      <StackPanel Grid.Row="0" Orientation="Horizontal" VerticalAlignment="Center" Margin="16,0,0,0">
        <Ellipse Name="BtnClose" Width="13" Height="13" Fill="#FF5F57" Cursor="Hand" Margin="0,0,8,0"/>
        <Ellipse Name="BtnMin" Width="13" Height="13" Fill="#FEBC2E" Cursor="Hand" Margin="0,0,8,0"/>
        <Ellipse Width="13" Height="13" Fill="#28C840"/>
      </StackPanel>
      <TextBlock Grid.Row="0" Text="Detector Epson EcoTank L14150" FontWeight="SemiBold" FontSize="13"
                 Foreground="#3C3C43" Opacity="0.85"
                 HorizontalAlignment="Center" VerticalAlignment="Center"/>

      <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" Margin="18,10,18,0">
        <StackPanel>
          <Border CornerRadius="10" Background="White" Padding="16,14" Margin="0,4,0,12">
            <StackPanel Orientation="Horizontal">
              <Ellipse Name="StatusDot" Width="16" Height="16" Fill="#FEBC2E" VerticalAlignment="Center"/>
              <StackPanel Margin="12,0,0,0" VerticalAlignment="Center">
                <TextBlock Name="StatusTitle" Text="Buscando impresoras..." FontSize="16" FontWeight="SemiBold" Foreground="#1D1D1F"/>
                <TextBlock Name="StatusSub" Text="Iniciando diagnostico..." FontSize="12" Foreground="#8E8E93" Margin="0,2,0,0"/>
              </StackPanel>
            </StackPanel>
          </Border>

          <TextBlock Text="DETALLES" FontSize="11" FontWeight="SemiBold" Foreground="#8E8E93" Margin="2,0,0,6"/>
          <Border CornerRadius="10" Background="White" Padding="12" Margin="0,0,0,14" MinHeight="140">
            <StackPanel Name="Findings"/>
          </Border>

          <UniformGrid Columns="4" Margin="0,0,0,8">
            <Button Name="BtnScan" Content="Escanear" Background="#007AFF" Foreground="White" Margin="0,0,6,0"/>
            <Button Name="BtnRepair" Content="Reparar" Background="#34C759" Foreground="White" Margin="6,0"/>
            <Button Name="BtnSettings" Content="Config." Background="#E5E5EA" Foreground="#1D1D1D" Margin="6,0"/>
            <Button Name="BtnSpooler" Content="Spooler" Background="#E5E5EA" Foreground="#1D1D1D" Margin="6,0,0,0"/>
          </UniformGrid>

          <UniformGrid Columns="2" Margin="0,0,0,10">
            <Button Name="BtnCleanDriver" Content="Limpiar driver danado" Background="#FF9500" Foreground="White" Margin="0,0,6,0"/>
            <Button Name="BtnDriver" Content="Descargar driver" Background="#5856D6" Foreground="White" Margin="6,0,0,0"/>
          </UniformGrid>
        </StackPanel>
      </ScrollViewer>

      <TextBlock Grid.Row="2" Name="FooterText" Text="Listo." FontSize="11" Foreground="#8E8E93"
                 Margin="20,0,20,10" VerticalAlignment="Center"/>
    </Grid>
  </Border>
</Window>
'@

# ------------------------------------------------------------- Icono
# PNG 64x64 (paleta) embebido en base64 -> icono de la ventana y de la app
$script:IconBase64 = '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'

function Add-WindowIcon {
    param($Window)
    try {
        $pngBytes = [Convert]::FromBase64String($script:IconBase64)
        $ms = New-Object System.IO.MemoryStream(,$pngBytes)
        $bitmap = New-Object System.Windows.Media.Imaging.BitmapFrame -ArgumentList $ms
        $Window.Icon = $bitmap
    } catch { }
}

# ------------------------------------------------------- Cargar XAML
[void][System.Reflection.Assembly]::LoadWithPartialName('PresentationFramework')

$xamlReader = New-Object System.Xml.XmlNodeReader -ArgumentList ([xml]$xamlText)
$Window = [Windows.Markup.XamlReader]::Load($xamlReader)
Add-WindowIcon -Window $Window

# Controles
$Findings   = $Window.FindName('Findings')
$StatusDot  = $Window.FindName('StatusDot')
$StatusTitle= $Window.FindName('StatusTitle')
$StatusSub  = $Window.FindName('StatusSub')
$FooterText = $Window.FindName('FooterText')
$BtnClose   = $Window.FindName('BtnClose')
$BtnMin     = $Window.FindName('BtnMin')
$BtnScan    = $Window.FindName('BtnScan')
$BtnSettings= $Window.FindName('BtnSettings')
$BtnSpooler = $Window.FindName('BtnSpooler')
$BtnCleanDriver = $Window.FindName('BtnCleanDriver')
$BtnDriver  = $Window.FindName('BtnDriver')

# ------------------------------------------------------- Utilidades UI
function Add-Finding {
    param($Text, $State)   # State: ok | warn | bad | info
    $colors = @{ ok='#28C840'; warn='#FEBC2E'; bad='#FF5F57'; info='#007AFF' }
    $border = New-Object System.Windows.Controls.Border
    $border.CornerRadius = 6
    $border.Padding = '10,7'
    $border.Margin = '0,0,0,6'
    $grid = New-Object System.Windows.Controls.Grid
    $dot = New-Object System.Windows.Shapes.Ellipse
    $dot.Width = 9; $dot.Height = 9
    $dot.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($colors[$State])
    $dot.VerticalAlignment = 'Center'
    $colDef = New-Object System.Windows.Controls.ColumnDefinition
    $colDef.Width = 'Auto'
    [void]$grid.ColumnDefinitions.Add($colDef)
    $colDef2 = New-Object System.Windows.Controls.ColumnDefinition
    [void]$grid.ColumnDefinitions.Add($colDef2)
    $txt = New-Object System.Windows.Controls.TextBlock
    $txt.Text = $Text
    $txt.FontSize = 12
    $txt.Foreground = '#3C3C43'
    $txt.VerticalAlignment = 'Center'
    $txt.Margin = '10,0,0,0'
    $txt.TextWrapping = 'Wrap'
    [System.Windows.Controls.Grid]::SetColumn($txt, 1)
    [void]$grid.Children.Add($dot)
    [void]$grid.Children.Add($txt)
    $border.Child = $grid
    [void]$Findings.Children.Add($border)
}

function Set-Status {
    param($Title, $Sub, $Color)
    $StatusTitle.Text = $Title
    $StatusSub.Text = $Sub
    $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
    $StatusDot.Fill = $brush
}

# ------------------------------------------------------- Deteccion
function Get-PrinterReport {
    $report = @()
    $spooler = Get-Service -Name Spooler
    if ($spooler.Status -eq 'Running') {
        $report += @{ Text='Servicio de impresion (Spooler): en ejecucion'; State='ok' }
    } else {
        $report += @{ Text='Servicio de impresion (Spooler): DETENIDO'; State='bad' }
    }

    $printers = Get-CimInstance -ClassName Win32_Printer
    $epsonPrinters = @($printers | Where-Object { $_.Name -match 'Epson' })
    $script:L14150Printers = @($epsonPrinters | Where-Object { $_.Name -match $script:Modelo })
    if ($script:L14150Printers.Count -gt 0) {
        $report += @{ Text="Impresora Epson $script:Modelo INSTALADA y activa"; State='ok' }
    } elseif ($epsonPrinters.Count -gt 0) {
        $report += @{ Text="Impresoras Epson instaladas: $($epsonPrinters.Count) (no se encontro $script:Modelo)"; State='warn' }
    } else {
        $report += @{ Text='No hay impresoras Epson instaladas'; State='warn' }
    }

    # Puertos huerfanos
    $ports = Get-CimInstance -ClassName Win32_TCPIPPrinterPort
    $usedPortNames = @($printers | ForEach-Object { $_.PortName })
    $orphans = @($ports | Where-Object { $usedPortNames -notcontains $_.Name })
    if ($orphans.Count -gt 0) {
        $report += @{ Text="Puertos de impresion huerfanos: $($orphans.Count) (rastro de impresoras borradas)"; State='warn' }
    }

    # Drivers Epson residuales
    $drivers = Get-CimInstance -ClassName Win32_PrinterDriver | Where-Object { $_.Name -match 'Epson' }
    $driverForL = @($drivers | Where-Object { $_.Name -match $script:Modelo })
    if ($driverForL.Count -gt 0 -and $script:L14150Printers.Count -eq 0) {
        $report += @{ Text="Driver Epson $script:Modelo residual (la impresora ya no existe)"; State='warn' }
    } elseif ($drivers.Count -gt 0) {
        $report += @{ Text="Drivers Epson instalados: $($drivers.Count)"; State='ok' }
    }

    # Historial USB
    $usb = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.DeviceID -match $script:VidEpson }
    if ($usb) {
        $present = @($usb | Where-Object { $_.Status -eq 'OK' })
        if ($present.Count -gt 0) {
            $report += @{ Text="Dispositivo Epson conectado por USB ahora mismo ($($present.Count))"; State='ok' }
        } else {
            $report += @{ Text='Rastros USB de dispositivos Epson (conectados en el pasado)'; State='info' }
        }
    }

    # Eventos de Windows
    $events = Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-PrintService/Operational'; Id=300,301,302 } -MaxEvents 5
    if ($events) {
        $report += @{ Text="Eventos recientes de impresion: $($events.Count) (instalacion/eliminacion)"; State='info' }
    }

    return $report
}

function Test-NetworkPrinter {
    # Escaneo rapido: tabla ARP + puerto 9100
    $found = $false
    $arp = arp -a 2>$null
    foreach ($line in $arp) {
        if ($line -match '\((\d+\.\d+\.\d+\.\d+)\)') {
            $ip = $Matches[1]
            $client = New-Object System.Net.Sockets.TcpClient
            try {
                $task = $client.ConnectAsync($ip, 9100)
                if ($task.Wait(120)) { $script:NetworkIP = $ip; $found = $true }
            } catch { } finally { $client.Close() }
        }
    }
    return $found
}

# ------------------------------------------------------- Reparacion (admin)
function Invoke-Repair {
    $FooterText.Text = 'Reparando...'

    # 1. Reiniciar Spooler si esta detenido
    $spooler = Get-Service -Name Spooler
    if ($spooler.Status -ne 'Running') {
        Start-Service -Name Spooler
        Add-Finding -Text 'Spooler iniciado' -State 'ok'
    }

    # 2. Eliminar puertos huerfanos
    $printers = Get-CimInstance -ClassName Win32_Printer
    $usedPortNames = @($printers | ForEach-Object { $_.PortName })
    $ports = Get-CimInstance -ClassName Win32_TCPIPPrinterPort
    $orphans = @($ports | Where-Object { $usedPortNames -notcontains $_.Name })
    $removedPorts = 0
    foreach ($port in $orphans) {
        try {
            Remove-PrinterPort -Name $port.Name -ErrorAction Stop
            $removedPorts++
        } catch { }
    }
    if ($removedPorts -gt 0) {
        Add-Finding -Text "Puertos huerfanos eliminados: $removedPorts" -State 'ok'
    }

    # 3. Desinstalar drivers Epson residuales (sin impresora asociada)
    $printers = Get-CimInstance -ClassName Win32_Printer
    $epsonPrinters = @($printers | Where-Object { $_.Name -match 'Epson' })
    $drivers = Get-CimInstance -ClassName Win32_PrinterDriver | Where-Object { $_.Name -match 'Epson' }
    $removedDrivers = 0
    foreach ($driver in $drivers) {
        $hasPrinter = $false
        foreach ($p in $epsonPrinters) {
            if ($p.DriverName -eq $driver.Name) { $hasPrinter = $true; break }
        }
        if (-not $hasPrinter) {
            try {
                Remove-PrinterDriver -Name $driver.Name -ErrorAction Stop
                $removedDrivers++
            } catch { }
        }
    }
    if ($removedDrivers -gt 0) {
        Add-Finding -Text "Drivers Epson residuales desinstalados: $removedDrivers" -State 'ok'
    }

    if ($removedPorts -eq 0 -and $removedDrivers -eq 0) {
        Add-Finding -Text 'No habia nada que reparar: puertos y drivers limpios' -State 'ok'
    }
    $FooterText.Text = "Reparacion completada - $(Get-Date -Format 'HH:mm:ss')"
}

# ------------------------------------------------------- Limpiar driver danado (admin)
function Invoke-CleanDamagedDriver {
    # Elimina la impresora Epson L14150 y su driver aunque esten en uso,
    # para dejar el terreno limpio antes de reinstalar el driver oficial.
    $FooterText.Text = 'Limpiando driver danado...'

    $removed = 0

    # 1. Eliminar las impresoras que usan drivers Epson L14150
    $printers = Get-CimInstance -ClassName Win32_Printer
    $lPrinters = @($printers | Where-Object { $_.Name -match $script:Modelo -or $_.DriverName -match $script:Modelo })
    foreach ($printer in $lPrinters) {
        try {
            Remove-Printer -Name $printer.Name -ErrorAction Stop
            Add-Finding -Text "Impresora eliminada: $($printer.Name)" -State 'ok'
        } catch { }
    }

    # 2. Eliminar el driver Epson L14150 (aunque este en uso)
    $drivers = Get-CimInstance -ClassName Win32_PrinterDriver | Where-Object { $_.Name -match $script:Modelo }
    foreach ($driver in $drivers) {
        try {
            # Intento normal
            Remove-PrinterDriver -Name $driver.Name -ErrorAction Stop
            Add-Finding -Text "Driver desinstalado: $($driver.Name)" -State 'ok'
        } catch {
            # Intento forzado via PrintUI (elimina driver en uso)
            try {
                Start-Process -FilePath 'rundll32' `
                    -ArgumentList @('printui.dll,PrintUIEntry', '/dd', "/n`"$($driver.Name)`"") `
                    -Wait -WindowStyle Hidden
                Add-Finding -Text "Driver forzado a eliminarse: $($driver.Name)" -State 'ok'
            } catch {
                Add-Finding -Text "No se pudo eliminar el driver: $($driver.Name)" -State 'bad'
            }
        }
    }

    # 3. Eliminar paquetes del DriverStore (restos .inf del driver danado)
    $pnputilOutput = @(pnputil /enum-drivers 2>$null)
    $infPackages = @()
    $current = $null
    foreach ($line in $pnputilOutput) {
        if ($line -match 'Published Name:\s*(oem\d+\.inf)') {
            if ($current) { $infPackages += $current }
            $current = @{ Inf = $Matches[1] }
        } elseif ($line -match 'Provider Name:\s*(.+)' -and $current) {
            $current.Provider = $Matches[1].Trim()
        } elseif ($line -match 'Original File Name:\s*(.+)' -and $current) {
            $current.Original = $Matches[1].Trim()
        }
    }
    if ($current) { $infPackages += $current }

    $removedPackages = 0
    foreach ($pkg in $infPackages) {
        $isEpsonL = ($pkg.Original -match 'Epson' -or $pkg.Original -match $script:Modelo) -and
                    ($pkg.Original -match $script:Modelo -or $pkg.Original -match 'L14150')
        if ($isEpsonL) {
            try {
                Start-Process -FilePath 'pnputil' `
                    -ArgumentList @('/delete-driver', $pkg.Inf, '/uninstall', '/force') `
                    -Wait -WindowStyle Hidden
                $removedPackages++
                Add-Finding -Text "Paquete residual eliminado del DriverStore: $($pkg.Inf)" -State 'ok'
            } catch { }
        }
    }
    if ($removedPackages -eq 0) {
        Add-Finding -Text 'DriverStore limpio: sin paquetes .inf residuales de la L14150' -State 'ok'
    }

    # 4. Reiniciar Spooler para liberar referencias
    try {
        Restart-Service -Name Spooler -Force
        Add-Finding -Text 'Spooler reiniciado (referencias liberadas)' -State 'ok'
    } catch { }

    # 5. Verificar resultado
    $remaining = Get-CimInstance -ClassName Win32_PrinterDriver | Where-Object { $_.Name -match $script:Modelo }
    if (-not $drivers -or @($drivers).Count -eq 0) {
        Add-Finding -Text 'No habia driver Epson L14150 instalado' -State 'info'
    } elseif (-not (Get-CimInstance -ClassName Win32_PrinterDriver | Where-Object { $_.Name -match $script:Modelo })) {
        Add-Finding -Text 'Terreno limpio: ya puedes instalar el driver oficial' -State 'ok'
    } else {
        Add-Finding -Text 'Quedan referencias del driver: reinicia el equipo y reintenta' -State 'warn'
    }
    $FooterText.Text = "Limpieza de driver completada - $(Get-Date -Format 'HH:mm:ss')"
}

# ------------------------------------------------------- Descargar driver
function Invoke-OpenDriverPage {
    # Abre el Download Center de Epson para la L14150 en el navegador del usuario
    $url = 'https://download-center.epson.com/softwares/?device_id=L14150+Series&region=GB&os=XP&language=en'
    try {
        Start-Process $url
        $FooterText.Text = 'Abriendo pagina oficial de descarga de Epson...'
    } catch {
        $FooterText.Text = 'No se pudo abrir el navegador'
    }
}

# ------------------------------------------------------- Escaneo
function Invoke-Scan {
    $Findings.Children.Clear()
    Set-Status -Title 'Buscando impresoras...' -Sub 'Ejecutando diagnostico completo...' -Color '#FEBC2E'
    $FooterText.Text = 'Escaneando...'

    $report = Get-PrinterReport
    foreach ($item in $report) { Add-Finding -Text $item.Text -State $item.State }

    $FooterText.Text = 'Escaneando red local...'
    if (Test-NetworkPrinter) {
        Add-Finding -Text "Impresora de red detectada en $script:NetworkIP (puerto 9100 abierto)" -State 'ok'
        if ($script:L14150Printers.Count -gt 0) {
            Set-Status -Title "Epson $script:Modelo detectada" -Sub "Activa en la red ($script:NetworkIP)" -Color '#28C840'
        } else {
            Set-Status -Title "Impresora de red encontrada" -Sub "IP: $script:NetworkIP - revisa si es la $script:Modelo" -Color '#28C840'
        }
    } else {
        Add-Finding -Text 'No se encontraron impresoras de red en la red local (puerto 9100)' -State 'info'
        if ($script:L14150Printers.Count -gt 0) {
            Set-Status -Title "Epson $script:Modelo detectada" -Sub 'Instalada en este equipo' -Color '#28C840'
        } else {
            Set-Status -Title "Epson $script:Modelo NO detectada" -Sub 'Conecta la impresora o instala el driver oficial' -Color '#FF5F57'
        }
    }
    $FooterText.Text = "Diagnostico completado - $(Get-Date -Format 'HH:mm:ss')"
}

# ------------------------------------------------------- Eventos
$BtnClose.Add_Click({ $Window.Close() })
$BtnMin.Add_Click({ $Window.WindowState = 'Minimized' })

$BtnScan.Add_Click({
    $BtnScan.IsEnabled = $false
    try { Invoke-Scan } finally { $BtnScan.IsEnabled = $true }
})

$BtnRepair.Add_Click({
    $BtnRepair.IsEnabled = $false
    try {
        Invoke-Repair
        Invoke-Scan
    } finally { $BtnRepair.IsEnabled = $true }
})

$BtnSettings.Add_Click({
    Start-Process 'ms-settings:printers'
})

$BtnSpooler.Add_Click({
    $FooterText.Text = 'Reiniciando Spooler...'
    try {
        Restart-Service -Name Spooler -Force
        $FooterText.Text = "Spooler reiniciado - $(Get-Date -Format 'HH:mm:ss')"
        Invoke-Scan
    } catch {
        $FooterText.Text = 'No se pudo reiniciar el Spooler (requiere permisos)'
    }
})

$BtnCleanDriver.Add_Click({
    $BtnCleanDriver.IsEnabled = $false
    try {
        Invoke-CleanDamagedDriver
        Invoke-Scan
    } finally { $BtnCleanDriver.IsEnabled = $true }
})

$BtnDriver.Add_Click({
    Invoke-OpenDriverPage
})

# ------------------------------------------------------- Inicio
$Window.Add_Loaded({ Invoke-Scan })
[void]$Window.ShowDialog()
