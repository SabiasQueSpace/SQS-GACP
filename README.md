# SQS-GACP - Gestionar y Analizar Conexiones y Procesos

Web: https://sabiasque.space

SQS-GACP es un script Batch para Windows que permite gestionar y analizar procesos, conexiones de red y puertos de forma sencilla.  
Entre sus funcionalidades se incluyen:

- Mostrar procesos activos.
- Ver conexiones de red activas mediante `netstat`.
- Analizar puertos y detectar conexiones sospechosas.
- Buscar procesos en ubicaciones inusuales.
- Finalizar procesos por PID.
- Bloquear IPs a través del Firewall de Windows.
- Comprobar si una IP es sospechosa consultando información DNS, WHOIS (ipinfo.io), AbuseIPDB y geolocalización (ip-api.com).

## Requisitos

- Windows (CMD)
- Herramientas nativas: `tasklist`, `netstat`, `wmic`, `netsh`, `taskkill`
- [cURL](https://curl.se/windows/) instalado y disponible en la variable de entorno PATH.
- Clave de API para AbuseIPDB (reemplazar en el script `"TU_API_KEY"`).

## Uso

1. Descarga o clona este repositorio.
2. Abre el archivo `SQS-GACP.bat` en un símbolo del sistema.
3. Sigue las instrucciones del menú para gestionar procesos y conexiones.

## Contribución

Las contribuciones son bienvenidas. Por favor, realiza un fork del repositorio y envía tus Pull Requests.

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
