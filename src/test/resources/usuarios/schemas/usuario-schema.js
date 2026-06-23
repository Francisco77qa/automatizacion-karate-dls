/**
 * Esquema reutilizable de un usuario, segun la forma real devuelta por
 * ServeRest tanto en GET /usuarios (cada item del array) como en
 * GET /usuarios/{id}.
 *
 * Uso:
 *   * def usuarioSchema = read('schemas/usuario-schema.js')
 *   * match response == usuarioSchema
 *   * match each response.usuarios == usuarioSchema
 */
{
  _id: '#regex [a-zA-Z0-9]{16}',
  nome: '#string',
  email: '#string',
  password: '#string',
  administrador: '#regex (true|false)'
}
