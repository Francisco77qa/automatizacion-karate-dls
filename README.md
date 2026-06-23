# Suite de Pruebas Automatizadas — API de Usuarios de ServeRest (Karate DSL)

Suite de pruebas automatizadas con **Karate DSL** para la API de **Usuarios**
de [ServeRest](https://serverest.dev) (`https://serverest.dev/usuarios`),
una API REST pública pensada específicamente para practicar automatización
de pruebas.

Todas las reglas de negocio y mensajes de error usados en este proyecto
fueron verificados directamente contra el **código fuente oficial** del
proyecto ([ServeRest/ServeRest](https://github.com/ServeRest/ServeRest),
archivos `usuarios-controller.js` y `usuarios-model.js`), no inventados ni
asumidos, para que las aserciones sean fieles al comportamiento real de la API.

## Estructura del proyecto

```
serverest-karate-usuarios/
├── pom.xml
├── README.md
├── .gitignore
└── src/test/
    ├── java/com/serverest/usuarios/
    │   └── UsuariosRunner.java          # Runner JUnit 5 que ejecuta la suite
    └── resources/
        ├── karate-config.js             # Config global (baseUrl, timeouts, ambientes)
        └── usuarios/
            ├── listar-usuarios.feature        # GET    /usuarios
            ├── buscar-usuario-por-id.feature  # GET    /usuarios/{id}
            ├── registro-usuario.feature      # POST   /usuarios
            ├── atualizar-usuario.feature      # PUT    /usuarios/{id}
            ├── deletar-usuario.feature        # DELETE /usuarios/{id}
            ├── schemas/
            │   └── usuario-schema.js          # Esquema JSON reutilizable de un usuario
            └── utils/
                └── generadorDatos.js            # Helper de generación de datos de prueba
```

## Requisitos previos

- **Java 17+** (`java -version`)
- **Maven 3.8+** (`mvn -version`)
- Conexión a internet (la suite corre contra `https://serverest.dev`, la
  instancia pública online)

## Cómo ejecutar

```bash
# Clonar/copiar el proyecto y entrar a la carpeta
cd serverest-karate-usuarios

# Ejecutar TODA la suite
mvn test
```

El reporte HTML se genera automáticamente en:
`target/karate-reports/karate-summary.html`

### Ejecutar solo un endpoint puntual

```bash
mvn test -Dkarate.options="classpath:usuarios/registro-usuario.feature"
```

### Ejecutar solo por etiqueta (tag)

Cada escenario está etiquetado por operación (`@get`, `@getOne`, `@post`,
`@put`, `@delete`), por tipo (`@positivo`, `@negativo`), y hay un subconjunto
`@smoke` con un caso feliz por endpoint.

```bash
mvn test -Dkarate.options="--tags @smoke"
mvn test -Dkarate.options="--tags @negativo"
mvn test -Dkarate.options="--tags @post and @positivo"
```

### Ejecutar contra otro ambiente

`karate-config.js` soporta un ambiente `local` (útil si corres ServeRest
localmente con `npx serverest@latest`, ver
[repo oficial](https://github.com/ServeRest/ServeRest)):

```bash
mvn test -Dkarate.env=local
```

## Qué cubre cada feature

| Feature | Endpoint | Casos positivos | Casos negativos |
|---|---|---|---|
| `listar-usuarios.feature` | `GET /usuarios` | Listado completo + validación de schema, filtro por email exacto, filtro sin resultados | Clave de búsqueda no soportada, `administrador` inválido, `email` con formato inválido |
| `buscar-usuario-por-id.feature` | `GET /usuarios/{id}` | Búsqueda por ID existente + validación de schema | ID con formato válido pero inexistente, ID que no cumple el formato de 16 caracteres alfanuméricos |
| `cadastrar-usuario.feature` | `POST /usuarios` | Alta de usuario común, alta de usuario administrador | Email duplicado, campos obligatorios faltantes, campo desconocido, `administrador` inválido (boolean/número/string libre), email con formato inválido |
| `atualizar-usuario.feature` | `PUT /usuarios/{id}` | Actualización de usuario existente, comportamiento *upsert* en ID inexistente | Email duplicado de otro usuario, campos obligatorios faltantes, `administrador` inválido |
| `deletar-usuario.feature` | `DELETE /usuarios/{id}` | Eliminación de usuario existente | Eliminación de ID inexistente (idempotente, no es error), usuario con carrinho asociado (`@bonus`, cruza con Login/Produtos/Carrinhos) |

Además, `listar-usuarios.feature` incluye un escenario `@security` que valida
los headers de seguridad que ServeRest agrega por defecto (documentados en
su propio README): `X-Content-Type-Options`, `X-Frame-Options`,
`X-XSS-Protection`, y la ausencia de `X-Powered-By`.

## Comportamientos importantes a tener en cuenta

Estos comportamientos están confirmados en el código fuente y pueden
sorprender si vienes de otras APIs REST "tradicionales":

- **`PUT` hace upsert**: si el `id` enviado en la URL no existe, ServeRest
  **crea** un usuario nuevo (con un `_id` generado por el servidor, distinto
  al de la URL) y responde `201`, en vez de fallar con `404`.
- **`DELETE` es idempotente y nunca falla por "no encontrado"**: borrar un
  `id` inexistente responde `200` con `message: 'Nenhum registro excluído'`,
  no un error.
- **`administrador` debe ser el string `'true'` o `'false'`**: enviarlo como
  booleano (`true`/`false` sin comillas) o número (`1`/`0`) es rechazado.
- **`GET /usuarios/{id}` exige exactamente 16 caracteres alfanuméricos** en
  el `id`; `PUT`/`DELETE` no tienen esa restricción de formato.
- Los mensajes de error de validación de body/query (Joi) se devuelven como
  un objeto donde **cada campo inválido es una clave**, por ejemplo:
  `{ "nome": "nome é obrigatório", "administrador": "administrador deve ser 'true' ou 'false'" }`.

## Helper de datos de prueba (`generadorDatos.js`)

Disponible como `generador` en todos los `.feature` (se registra una sola vez
en `karate-config.js`):

```javascript
generador.generarUsuario()            // usuario completo, administrador aleatorio
generador.generarUsuario('true')      // usuario completo, forzado a administrador
generador.generarNomeCompleto()
generador.geerarEmail()              // único por timestamp + sufijo aleatorio
generador.generarSenha()
generador.generarAdministrador()      // 'true' | 'false'
generador.generarId16CaracteresAleatorios()  // formato válido de _id de ServeRest
generador.generarIdAleatorio()        // id de longitud arbitraria, para PUT/DELETE
```

Los emails se generan con timestamp + sufijo aleatorio para minimizar
colisiones contra la base de datos compartida de la instancia pública
(que se resetea diariamente, pero es usada por mucha gente en paralelo).

## Validación de esquema JSON

`schemas/usuario-schema.js` define el shape esperado de un usuario usando
los marcadores nativos de Karate (`#string`, `#regex ...`):

```javascript
{
  _id: '#regex [a-zA-Z0-9]{16}',
  nome: '#string',
  email: '#string',
  password: '#string',
  administrador: '#regex (true|false)'
}
```

Se reutiliza tanto para validar cada elemento del array en `GET /usuarios`
(`match each response.usuarios == usuarioSchema`) como la respuesta completa
de `GET /usuarios/{id}` (`match response == usuarioSchema`).

## Limitaciones y posibles próximos pasos

- El escenario `@bonus` de `deletar-usuario.feature` depende de las APIs de
  **Login**, **Produtos** y **Carrinhos** solo para construir la
  precondición ("usuario con carrinho"); si se quiere una suite 100%
  aislada a Usuarios, se puede excluir con `--tags ~@bonus`.
- Al correr contra la instancia pública compartida, es posible (aunque poco
  probable) ver fallos intermitentes por latencia o carga de otros usuarios
  ejecutando pruebas al mismo tiempo. Si se necesita aislamiento total,
  ejecuta ServeRest localmente (`npx serverest@latest`) y corre con
  `-Dkarate.env=local`.
- Este proyecto cubre **solo el módulo Usuarios**. La misma estructura
  (feature por endpoint, schema reutilizable, helper de datos) se puede
  replicar para Login, Produtos y Carrinhos.

## Sobre la versión de Karate

El `pom.xml` usa `io.karatelabs:karate-junit5:1.5.2` (Karate 1.x, el grupo
fue renombrado de `com.intuit.karate` a `io.karatelabs`). Karate también
tiene una versión 2.x (`karate-junit6`) que requiere Java 21+; si quieres
migrar, revisa la guía oficial de migración antes de actualizar, ya que
cambia el artifactId y el manejo de la dependencia de JUnit.
