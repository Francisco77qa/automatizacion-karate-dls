Feature: Buscar usuário por ID - GET /usuarios/{id}

  Regras confirmadas no código-fonte do ServeRest (usuarios-model.js):
    - o parâmetro "id" deve ter exatamente 16 caracteres alfanuméricos,
      caso contrário retorna 400 com uma mensagem específica de formato
    - se o formato é válido mas o id não existe, retorna 400 com
      message: 'Usuário não encontrado'

  Background:
    * url baseUrl
    * def usuarioSchema = read('schemas/usuario-schema.js')
    * def usuarioNovo = generador.generarUsuario()
    Given path 'usuarios'
    And request usuarioNovo
    When method POST
    Then status 201
    * def idUsuario = response._id

  @smoke @getOne @positivo
  Scenario: Buscar um usuário existente pelo ID retorna 200 com os dados corretos
    Given path 'usuarios', idUsuario
    When method GET
    Then status 200
    And match response == usuarioSchema
    And match response ==
      """
      {
        _id: '#(idUsuario)',
        nome: '#(usuarioNovo.nome)',
        email: '#(usuarioNovo.email)',
        password: '#(usuarioNovo.password)',
        administrador: '#(usuarioNovo.administrador)'
      }
      """

  @getOne @negativo
  Scenario: Buscar um ID com formato válido (16 caracteres) mas inexistente retorna 400
    * def idComFormatoValidoPoremInexistente = generador.generarId16CaracteresAleatorios()
    Given path 'usuarios', idComFormatoValidoPoremInexistente
    When method GET
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @getOne @negativo
  Scenario Outline: Buscar com um ID que não possui exatamente 16 caracteres alfanuméricos retorna 400
    Given path 'usuarios', '<idInvalido>'
    When method GET
    Then status 400
    And match response == { id: 'id deve ter exatamente 16 caracteres alfanuméricos' }

    Examples:
      | idInvalido          |
      | abc                 |
      | 123456789012345678  |
      | idDeFormatoInvalido |
