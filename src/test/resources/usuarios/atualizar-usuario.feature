Feature: Atualizar usuário - PUT /usuarios/{id}

  Comportamento confirmado no código-fonte do ServeRest (usuarios-controller.js):
    - PUT em um ID EXISTENTE atualiza os dados e retorna 200
      com message: 'Registro alterado com sucesso'
    - PUT em um ID INEXISTENTE faz um "upsert": cria um novo registro
      (com um novo _id gerado pelo servidor, diferente do id enviado na
      URL) e retorna 201 com message: 'Cadastro realizado com sucesso'
    - o body exige os mesmos campos obrigatórios do POST
    - não é permitido usar um email que já pertence a outro usuário

  Background:
    * url baseUrl

  @smoke @put @positivo
  Scenario: Atualizar um usuário existente com dados válidos retorna 200
    * def usuarioOriginal = generador.generarUsuario()
    Given path 'usuarios'
    And request usuarioOriginal
    When method POST
    Then status 201
    * def idUsuario = response._id

    * def usuarioAtualizado = generador.generarUsuario()
    * set usuarioAtualizado.email = usuarioOriginal.email
    Given path 'usuarios', idUsuario
    And request usuarioAtualizado
    When method PUT
    Then status 200
    And match response == { message: 'Registro alterado com sucesso' }

    Given path 'usuarios', idUsuario
    When method GET
    Then status 200
    And match response.nome == usuarioAtualizado.nome
    And match response.administrador == usuarioAtualizado.administrador

  @put @positivo
  Scenario: Enviar PUT para um ID inexistente cria um novo registro (upsert) e retorna 201
    * def usuarioNovo = generador.generarUsuario()
    * def idInexistente = generador.generarIdAleatorio()
    Given path 'usuarios', idInexistente
    And request usuarioNovo
    When method PUT
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#string' }
    And match response._id != idInexistente

  @put @negativo
  Scenario: Atualizar um usuário usando um e-mail que já pertence a outro usuário retorna 400
    * def usuarioA = generador.generarUsuario()
    Given path 'usuarios'
    And request usuarioA
    When method POST
    Then status 201

    * def usuarioB = generador.generarUsuario()
    Given path 'usuarios'
    And request usuarioB
    When method POST
    Then status 201
    * def idUsuarioB = response._id

    * set usuarioB.email = usuarioA.email
    Given path 'usuarios', idUsuarioB
    And request usuarioB
    When method PUT
    Then status 400
    And match response == { message: 'Este email já está sendo usado' }

  @put @negativo
  Scenario: Atualizar sem enviar nenhum campo obrigatório retorna 400 com todas as mensagens
    * def idQualquer = generador.generarIdAleatorio()
    Given path 'usuarios', idQualquer
    And request {}
    When method PUT
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

  @put @negativo
  Scenario: Atualizar com 'administrador' em formato inválido retorna 400
    * def idQualquer = generador.generarIdAleatorio()
    * def usuario = generador.generarUsuario()
    * set usuario.administrador = 1
    Given path 'usuarios', idQualquer
    And request usuario
    When method PUT
    Then status 400
    And match response.administrador == "administrador deve ser 'true' ou 'false'"
