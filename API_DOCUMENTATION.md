# Documentación de la API de Searchpe (Servicio de Búsqueda de Contribuyentes - SUNAT)

Esta documentación detalla los endpoints de la API REST de **Searchpe**, la estructura de las peticiones, ejemplos de consumo en múltiples lenguajes (JavaScript y Java) y guías de prueba en Postman.

---

## Información General

La API de **Searchpe** es un servicio REST desarrollado sobre **Quarkus** que permite consultar información fiscal de contribuyentes del Perú de manera ágil y eficiente.

* **URL Base de la API:** `http://localhost:8180/api`
* **Formato de Comunicación:** JSON (`application/json`)
* **Soporte CORS:** Habilitado por defecto (`Origins: *`), lo que permite consumir la API directamente desde aplicaciones frontend (React, Angular, Vue) sin bloqueos del navegador.

---

## Seguridad y Autenticación

El comportamiento de la seguridad se controla a través de la propiedad `searchpe.disable.authorization` en el archivo [application.properties](file:///c:/Users/ASUS/Downloads/searchpe-4.1.1/searchpe-4.1.1/config/application.properties):

1. **Modo Desarrollo (Seguridad Desactivada - Configuración Actual):**
   * Propiedad: `searchpe.disable.authorization=true`
   * Todas las peticiones HTTP a los endpoints de consulta se pueden realizar directamente **sin cabeceras ni credenciales de autenticación** (Modo abierto).
2. **Modo Producción (Seguridad Activada - Basic Auth):**
   * Propiedad: `searchpe.disable.authorization=false`
   * Requiere cabecera de autenticación HTTP Basic (`Authorization: Basic <credenciales_encriptadas>`) utilizando un usuario registrado en la tabla `BASIC_USER`.

---

## Catálogo de Endpoints

### 1. Obtener Contribuyente por número de RUC
Busca y devuelve la ficha de información fiscal de un contribuyente específico mediante su número de RUC.

* **Método:** `GET`
* **Ruta:** `/contribuyentes/{ruc}`
* **Ejemplo de URL:** `http://localhost:8180/api/contribuyentes/20100078941`

#### Respuesta Esperada (`200 OK`):
```json
{
  "ruc": "20100078941",
  "nombre": "ACME PERU S.A.C.",
  "estado": "ACTIVO",
  "condicionDomicilio": "HABIDO",
  "ubigeo": "150101",
  "tipoVia": "AVENIDA",
  "nombreVia": "AREQUIPA",
  "numero": "1234",
  "interior": "401",
  "departamento": "LIMA",
  "codigoZona": "URB",
  "tipoZona": "URBANIZACION SANTA BEATRIZ"
}
```

* **Código `404 Not Found`:** Retornado si el RUC consultado no existe en la base de datos local.

---

### 2. Buscar / Listar Contribuyentes (Búsqueda Avanzada)
Permite buscar contribuyentes mediante filtros y paginación. 

* **Método:** `GET`
* **Ruta:** `/contribuyentes`
* **Ejemplo de URL:** `http://localhost:8180/api/contribuyentes?filterText=PERU&limit=3`

#### Parámetros de Consulta (Query Params):
| Parámetro | Tipo | Requerido | Descripción |
| :--- | :--- | :--- | :--- |
| `filterText` | String | No | Texto clave a buscar en la Razón Social (nombre) o número de RUC. |
| `limit` | Integer | No | Límite de registros devueltos por página (Por defecto: `20`, Máximo: `100`). |
| `offset` | Integer | No | Índice inicial del paginado (Por defecto: `0`). |
| `sort_by` | String | No | Campo por el cual ordenar los registros (ej. `nombre`). |

#### Respuesta Esperada (`200 OK`):
```json
{
  "data": [
    {
      "ruc": "20100078941",
      "nombre": "ACME PERU S.A.C.",
      "estado": "ACTIVO",
      "condicionDomicilio": "HABIDO",
      "ubigeo": "150101",
      "tipoVia": "AVENIDA",
      "nombreVia": "AREQUIPA",
      "numero": "1234",
      "interior": "401",
      "departamento": "LIMA",
      "codigoZona": "URB",
      "tipoZona": "URBANIZACION SANTA BEATRIZ"
    },
    {
      "ruc": "10427891234",
      "dni": "42789123",
      "nombre": "JUAN PEREZ DIAZ",
      "estado": "ACTIVO",
      "condicionDomicilio": "HABIDO",
      "ubigeo": "150130",
      "tipoVia": "CALLE",
      "nombreVia": "LOS ROSALES",
      "numero": "456",
      "departamento": "LIMA",
      "codigoZona": "RES",
      "tipoZona": "RESIDENCIAL"
    }
  ],
  "meta": {
    "count": 2
  }
}
```

---

### 3. Consultar Versiones del Padrón Cargadas
Lista la información sobre el estado de las descargas y actualizaciones de datos en la base de datos.

* **Método:** `GET`
* **Ruta:** `/versions`
* **Ejemplo de URL:** `http://localhost:8180/api/versions`

#### Respuesta Esperada (`200 OK`):
```json
[
  {
    "id": 1,
    "createdAt": "2026-05-30T00:35:41Z",
    "updatedAt": "2026-05-30T00:35:41Z",
    "status": "COMPLETED",
    "records": 10,
    "version": 1,
    "triggerKey": "manual"
  }
]
```

---

## Ejemplos de Integración de Código

### Ejemplo en JavaScript (Fetch - Frontend / Node.js)
```javascript
const URL_BASE = 'http://localhost:8180/api';

async function buscarContribuyente(ruc) {
  try {
    const response = await fetch(`${URL_BASE}/contribuyentes/${ruc}`);
    
    if (response.status === 404) {
      console.log('El RUC no existe.');
      return;
    }
    
    const contribuyente = await response.json();
    console.log('Ficha RUC cargada:', contribuyente);
  } catch (error) {
    console.error('Error de conexión con la API:', error);
  }
}

// Ejecución
buscarContribuyente('20100078941');
```

### Ejemplo en Java (HttpClient - Java 11+)
```java
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class SearchpeClient {
    public static void main(String[] args) {
        String ruc = "20100078941";
        String url = "http://localhost:8180/api/contribuyentes/" + ruc;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .header("Accept", "application/json")
                .build();

        try {
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                System.out.println("JSON recibido: " + response.body());
            } else {
                System.out.println("Error. Estado HTTP: " + response.statusCode());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

---

## Datos de Prueba Disponibles (Padrón Reducido Simulado)

Puedes probar consultas rápidas utilizando los siguientes números de RUC agregados a la base de datos:

| RUC | Razón Social / Nombre | Tipo Contribuyente | Estado / Domicilio |
| :--- | :--- | :--- | :--- |
| **`20100078941`** | ACME PERU S.A.C. | Persona Jurídica | ACTIVO / HABIDO |
| **`10427891234`** | JUAN PEREZ DIAZ (DNI: 42789123) | Persona Natural | ACTIVO / HABIDO |
| **`20551234567`** | TIENDA MULTICOMPRAS E.I.R.L. | Persona Jurídica | ACTIVO / HABIDO |
| **`20601234568`** | CONSTRUCTORA DEL NORTE S.A. | Persona Jurídica | ACTIVO / HABIDO |
| **`10098765432`** | MARIA ALVA GOMEZ (DNI: 09876543) | Persona Natural | ACTIVO / HABIDO |
| **`20489562314`** | AGROEXPORTACIONES SAC | Persona Jurídica | ACTIVO / HABIDO |
| **`10712345678`** | CARLOS SANCHEZ FLORES (DNI: 71234567) | Persona Natural | ACTIVO / HABIDO |
| **`20543216789`** | TECNOLOGIA INTEGRAL PERU S.A.C. | Persona Jurídica | ACTIVO / HABIDO |
| **`10459876123`** | ANA TORRES RAMOS (DNI: 45987612) | Persona Natural | ACTIVO / HABIDO |
| **`20876543210`** | LOGISTICA Y TRANSPORTES S.A. | Persona Jurídica | ACTIVO / HABIDO |
