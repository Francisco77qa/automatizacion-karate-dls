Feature: Listar usuários - GET /usuarios

  Endpoint que lista os usuários cadastrados, com suporte a filtros via
  query string: _id, nome, email, password, administrador.
  Regras confirmadas no código-fonte do ServeRest (usuarios-model.js):
    - email deve ter formato de email válido, se informado
    - administrador só aceita os valores string 'true' ou 'false'
    - chaves de busca não suportadas retornam 400

  Background:
    * url baseUrl
    * def usuarioSchema = read('schemas/usuario-schema.js')

  @smoke @get @positivo
  Scenario: Listar todos os usuários retorna 200 com estrutura e schema válidos
    Given path 'usuarios'
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#array'
    And match each response.usuarios == usuarioSchema

  @get @positivo
  Scenario: Filtrar por email de um usuário recém-criado retorna exatamente esse usuário
    * def usuarioCriado = generador.generarUsuario()
    Given path 'usuarios'
    And request usuarioCriado
    When method POST
    Then status 201
    * def idCriado = response._id

    Given path 'usuarios'
    And param email = usuarioCriado.email
    When method GET
    Then status 200
    And match response.quantidade == 1
    And match response.usuarios[0] ==
      """
      {
        _id: '#(idCriado)',
        nome: '#(usuarioCriado.nome)',
        email: '#(usuarioCriado.email)',
        password: '#(usuarioCriado.password)',
        administrador: '#(usuarioCriado.administrador)'
      }
      """

  @get @positivo
  Scenario: Filtrar por um email que não existe retorna lista vazia
    Given path 'usuarios'
    And param email = generador.generarEmail()
    When method GET
    Then status 200
    And match response == { quantidade: 0, usuarios: [] }

  @get @negativo
  Scenario: Filtrar usando uma chave de busca não suportada retorna 400
    Given path 'usuarios'
    And param chaveInvalida = 'qualquerValor'
    When method GET
    Then status 400
    And match response == { chaveInvalida: 'chaveInvalida não é permitido' }

  @get @negativo
  Scenario: Filtrar com administrador fora de 'true'/'false' retorna 400
    Given path 'usuarios'
    And param administrador = 'talvez'
    When method GET
    Then status 400
    And match response.administrador == "administrador deve ser 'true' ou 'false'"

  @get @negativo
  Scenario: Filtrar com email em formato inválido retorna 400
    Given path 'usuarios'
    And param email = 'isto-nao-e-um-email'
    When method GET
    Then status 400
    And match response.email == 'email deve ser um email válido'

  @security
  Scenario: Validar headers de segurança padrão expostos pelo ServeRest
    # Conforme documentado em https://github.com/ServeRest/ServeRest
    Given path 'usuarios'
    When method GET
    Then status 200
    And match responseHeaders['X-Content-Type-Options'][0] == 'nosniff'
    And match responseHeaders['X-Frame-Options'][0] == 'SAMEORIGIN'
    And match responseHeaders['X-XSS-Protection'][0] == '1; mode=block'
    And match responseHeaders['X-Powered-By'] == '#notpresent'
