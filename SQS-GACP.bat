@echo off
chcp 65001
rem --- secuencias ANSI
for /F "delims=" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

rem --- Colores
set "GREEN=%ESC%[32m"
set "WHITE=%ESC%[37m"
set "RED=%ESC%[31m"
set "YELLOW=%ESC%[33m"
set "RESET=%ESC%[0m"

rem --- Configuración de claves API
set "ABUSEIPDB_API_KEY=TU_API_KEY"

title Gestionar Procesos y Conexiones en Windows
cls

:main_menu
cls
echo %GREEN%===================================================
echo       Gestionar y Analizar Conexiones y Procesos
echo             Por https://sabiasque.space
echo %GREEN%===================================================
echo %WHITE%1. Mostrar todos los procesos activos
echo 2. Mostrar conexiones de red activas (netstat)
echo 3. Analizar puertos y conexiones sospechosas
echo 4. Buscar procesos sospechosos
echo 5. Finalizar un proceso por PID
echo 6. Bloquear una IP en el Firewall
echo 7. Comprobar si una IP es sospechosa
echo 8. Administrar IPs bloqueadas en el Firewall
echo 9. Salir
echo %GREEN%===================================================
set /p opcion=%YELLOW%Selecciona una opción: %RESET%

if "%opcion%"=="1" goto mostrar_procesos
if "%opcion%"=="2" goto mostrar_netstat
if "%opcion%"=="3" goto analizar_puertos
if "%opcion%"=="4" goto buscar_sospechosos
if "%opcion%"=="5" goto finalizar_proceso
if "%opcion%"=="6" goto bloquear_ip
if "%opcion%"=="7" goto comprobar_ip
if "%opcion%"=="8" goto administrar_firewall
if "%opcion%"=="9" goto salir

echo %RED%Opción inválida. Presiona cualquier tecla para volver al menú.%RESET%
pause >nul
goto main_menu

:mostrar_procesos
cls
echo %GREEN%===================================================
echo Procesos Activos:
echo %GREEN%===================================================%RESET%
tasklist | more
pause
goto main_menu

:mostrar_netstat
cls
echo %GREEN%===================================================
echo Conexiones de Red Activas:
echo %GREEN%===================================================%RESET%
netstat -ano | more
pause
goto main_menu

:analizar_puertos
cls
echo %GREEN%===================================================
echo Analizando conexiones en puertos sospechosos...
echo %GREEN%===================================================%RESET%
echo.

rem --- Conexiones activas en puertos no comunes (excluye puertos comunes: 3306, 5000, 8000)
echo %WHITE%==== Conexiones activas en puertos no comunes ==== %RESET%
netstat -ano | findstr /R /C:":[1-9][0-9][0-9][0-9][0-9]" | findstr /V /C:":3306 " /C:":5000 " /C:":8000 "
echo.

rem --- Conexiones ESTABLISHED en puertos inusuales
echo %WHITE%==== Conexiones ESTABLISHED sospechosas ==== %RESET%
for /f "tokens=5" %%A in ('netstat -ano ^| findstr "ESTABLISHED"') do (
    echo %%A | findstr /R /C:":[1-9][0-9][0-9][0-9][0-9]"
)
echo.

rem --- Procesos asociados a puertos sospechosos
echo %WHITE%==== Procesos asociados a puertos sospechosos ==== %RESET%
for /f "tokens=5" %%A in ('netstat -ano ^| findstr "ESTABLISHED"') do (
    for /f "tokens=2 delims= " %%B in ('netstat -ano ^| findstr "%%A"') do (
        tasklist | findstr /C:"%%B"
    )
)
echo.
pause
goto main_menu

:buscar_sospechosos
cls
echo %GREEN%===================================================
echo Buscando procesos sospechosos...
echo %GREEN%===================================================%RESET%
echo.

rem --- Verifica procesos en ubicaciones inusuales (excluye SystemRoot)
echo %WHITE%Procesos con rutas inusuales:%RESET%
for /f "tokens=1,2 delims=," %%A in ('wmic process get ProcessId,ExecutablePath /format:csv ^| findstr /i /v "SystemRoot"') do (
    echo PID: %%A - %%B
)
echo.
pause

rem --- Conexiones en puertos no comunes
echo %WHITE%===================================================%RESET%
echo %WHITE%Conexiones a puertos no comunes:%RESET%
netstat -ano | findstr /R /C:":[1-9][0-9][0-9][0-9][0-9]"
echo.
pause

rem --- Conexiones con IPs sospechosas predefinidas
echo %WHITE%===================================================%RESET%
echo %WHITE%Conexiones con IPs sospechosas:%RESET%
for /f "tokens=5" %%A in ('netstat -ano ^| findstr "ESTABLISHED"') do (
    echo %%A | findstr /R /C:"185.250.240.81" /C:"144.91.107.170"
)
echo.
pause
goto main_menu

:finalizar_proceso
cls
echo %GREEN%===================================================
echo Finalizar un proceso por PID
echo %GREEN%===================================================%RESET%
set /p pid=%YELLOW%Introduce el PID del proceso a finalizar: %RESET%
taskkill /PID %pid% /F
echo %GREEN%Proceso %pid% finalizado.%RESET%
pause
goto main_menu

:bloquear_ip
cls
echo %GREEN%===================================================
echo Bloquear una IP en el Firewall
echo %GREEN%===================================================%RESET%
set /p ip=%YELLOW%Introduce la IP que deseas bloquear: %RESET%
netsh advfirewall firewall add rule name="Bloquear IP %ip%" dir=out action=block remoteip=%ip%
echo %GREEN%IP %ip% bloqueada en el Firewall.%RESET%
pause
goto main_menu

:comprobar_ip
cls
echo %GREEN%===================================================
echo Comprobar si una IP es sospechosa - Detalles
echo %GREEN%===================================================%RESET%
set /p ip=%YELLOW%Introduce la IP que deseas analizar: %RESET%
echo.

rem --- 1. Conexiones activas con la IP
echo %WHITE%[1] Conexiones activas con %ip%:%RESET%
netstat -ano | findstr "%ip%"
echo %GREEN%===================================================%RESET%

rem --- 2. Reglas del Firewall relacionadas con la IP
echo %WHITE%[2] Reglas del Firewall para %ip%:%RESET%
netsh advfirewall firewall show rule name=all | findstr "%ip%"
echo %GREEN%===================================================%RESET%

rem --- 3. Consulta DNS con nslookup
echo %WHITE%[3] Consultando información DNS con nslookup...%RESET%
nslookup %ip% > tmp_nslookup.txt 2>&1
if errorlevel 1 (
    echo %RED%Error: nslookup falló en obtener información para %ip%.%RESET%
) else (
    type tmp_nslookup.txt
)
del tmp_nslookup.txt
echo %GREEN%===================================================%RESET%

rem --- 4. Información WHOIS desde ipinfo.io
echo %WHITE%[4] Consultando información WHOIS desde ipinfo.io...%RESET%
curl -s -A "Mozilla/5.0" https://ipinfo.io/%ip% > tmp_ipinfo.txt
if errorlevel 1 (
    echo %RED%Error: No se pudo obtener información de ipinfo.io.%RESET%
) else (
    echo %WHITE%Información de ipinfo.io:%RESET%
    type tmp_ipinfo.txt
)
del tmp_ipinfo.txt
echo %GREEN%===================================================%RESET%

rem --- 5. Reporte de abuso en AbuseIPDB
echo %WHITE%[5] Consultando reporte en AbuseIPDB...%RESET%
curl -s -A "Mozilla/5.0" "https://api.abuseipdb.com/api/v2/check?ipAddress=%ip%" -H "Key: %ABUSEIPDB_API_KEY%" -H "Accept: application/json" > tmp_abuseipdb.txt
if errorlevel 1 (
    echo %RED%Error: No se pudo obtener información de AbuseIPDB.%RESET%
) else (
    echo %WHITE%Reporte de AbuseIPDB:%RESET%
    type tmp_abuseipdb.txt
)
del tmp_abuseipdb.txt
echo %GREEN%===================================================%RESET%

rem --- 6. Información de geolocalización desde ip-api.com
echo %WHITE%[6] Consultando información de geolocalización desde ip-api.com...%RESET%
curl -s -A "Mozilla/5.0" http://ip-api.com/json/%ip% > tmp_ipapi.txt
if errorlevel 1 (
    echo %RED%Error: No se pudo obtener información de ip-api.com.%RESET%
) else (
    echo %WHITE%Información de ip-api.com:%RESET%
    type tmp_ipapi.txt
)
del tmp_ipapi.txt
echo.
echo %GREEN%===================================================%RESET%

echo.
set /p respuesta=%YELLOW%¿Quieres bloquear esta IP en el Firewall? (S/N): %RESET%
if /I "%respuesta%"=="S" goto bloquear_ip
pause
goto main_menu

:administrar_firewall
cls
echo %GREEN%===================================================
echo Administración del Firewall - IPs Bloqueadas
echo %GREEN%===================================================%RESET%
netsh advfirewall firewall show rule name=all | findstr "RemoteIP"
echo %GREEN%===================================================%RESET%
set /p respuesta=%YELLOW%¿Deseas eliminar una IP bloqueada? (S/N): %RESET%
if /I "%respuesta%"=="S" goto eliminar_ip_bloqueada
pause
goto main_menu

:eliminar_ip_bloqueada
cls
echo %GREEN%===================================================
echo Eliminar una IP del Firewall
echo %GREEN%===================================================%RESET%
set /p ip=%YELLOW%Introduce la IP que deseas desbloquear: %RESET%
netsh advfirewall firewall delete rule name="Bloquear IP %ip%"
echo %GREEN%IP %ip% eliminada del Firewall.%RESET%
pause
goto main_menu

:salir
cls
echo %GREEN%Saliendo del programa...%RESET%
pause
exit
