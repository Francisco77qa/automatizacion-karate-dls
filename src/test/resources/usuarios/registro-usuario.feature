Feature: Cadastrar usuário - POST /usuarios

  Regras confirmadas no código-fonte do ServeRest (usuarios-controller.js
  e usuarios-model.js):
    - nome, email, password e administrador são obrigatórios
    - administrador só aceita o STRING 'true' ou 'false' (não booleano,
      não número)
    - email deve ter formato válido
    - não é permitido cadastrar dois usuários com o mesmo email
    - chaves desconhecidas no body são rejeitadas

  Background:
    * url baseUrl

  @smoke @post @positivo
  Scenario: Registrar un usuario comun con dados válidos retorna 201
    * def nuevoUsuario = generador.generarUsuario('false')
    Given path 'usuarios'
    And request nuevoUsuario
    When method POST
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#regex [a-zA-Z0-9]{16}' }

  @post @positivo
  Scenario: Registrar un usuario administrador con datos válidos retorna 201
    * def nuevoAdmin = generador.generarUsuario('true')
    Given path 'usuarios'
    And request nuevoAdmin
    When method POST
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#regex [a-zA-Z0-9]{16}' }
    * def idCriado = response._id

    # Confirma que o usuario es realmente persistido como administrador
    Given path 'usuarios', idCriado
    When method GET
    Then status 200
    And match response.administrador == 'true'

  @post @negativo
  Scenario: Registrar usuario com e-mail já utilizado retorna 400
    * def usuario = generador.generarUsuario()
    Given path 'usuarios'
    And request usuario
    When method POST
    Then status 201

    Given path 'usuarios'
    And request usuario
    When method POST
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

  @post @negativo
  Scenario: Registrar usuario sem nenhum campo obrigatório retorna 400 com todas as mensagens
    Given path 'usuarios'
    And request {}
    When method POST
    Then status 400
    And match response ==
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório'
      }
      """

  @post @negativo
  Scenario: Registrar usuario enviando um campo desconhecido retorna erro indicando o campo não permitido
    Given path 'usuarios'
    And request { inexistente: '1' }
    When method POST
    Then status 400
    And match response ==
      """
      {
        nome: 'nome é obrigatório',
        email: 'email é obrigatório',
        password: 'password é obrigatório',
        administrador: 'administrador é obrigatório',
        inexistente: 'inexistente não é permitido'
      }
      """

  @post @negativo
  Scenario Outline: Cadastrar usuário com 'administrador' em formato inválido retorna 400
    * def usuario = generador.generarUsuario()
    * set usuario.administrador = <valorAdministrador>
    Given path 'usuarios'
    And request usuario
    When method POST
    Then status 400
    And match response.administrador == "administrador deve ser 'true' ou 'false'"

    Examples:
      | valorAdministrador |
      | true               |
      | false              |
      | 1                  |
      | 'sim'              |

  @post @negativo
  Scenario: Cadastrar usuário com e-mail em formato inválido retorna 400
    * def usuario = generador.generarUsuario()
    * set usuario.email = 'email-sem-formato-valido'
    Given path 'usuarios'
    And request usuario
    When method POST
    Then status 400
    And match response.email == 'email deve ser um email válido'
