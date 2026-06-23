Feature: Deletar usuário - DELETE /usuarios/{id}

  Comportamento confirmado no código-fonte do ServeRest (usuarios-controller.js):
    - deletar um ID existente retorna 200 com message: 'Registro excluído com sucesso'
    - deletar um ID inexistente também retorna 200 (não é erro), porém com
      message: 'Nenhum registro excluído' (operação idempotente)
    - não é permitido excluir um usuário que possui carrinho cadastrado
      (regra de negócio que cruza com a API de Carrinhos)

  Background:
    * url baseUrl

  @smoke @delete @positivo
  Scenario: Deletar um usuário existente retorna 200 e remove o registro
    * def usuario = generador.generarUsuario()
    Given path 'usuarios'
    And request usuario
    When method POST
    Then status 201
    * def idUsuario = response._id

    Given path 'usuarios', idUsuario
    When method DELETE
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }

    Given path 'usuarios', idUsuario
    When method GET
    Then status 400
    And match response == { message: 'Usuário não encontrado' }

  @delete @positivo
  Scenario: Deletar um ID que não existe retorna 200 indicando que nenhum registro foi excluído
    * def idInexistente = generador.generarIdAleatorio()
    Given path 'usuarios', idInexistente
    When method DELETE
    Then status 200
    And match response == { message: 'Nenhum registro excluído' }

  @delete @negativo @bonus
  Scenario: Não deve ser possível deletar um usuário que possui carrinho cadastrado
    # Cenário "ponta a ponta" que cruza com as APIs de Login, Produtos e
    # Carrinhos apenas para montar a pré-condição (usuário com carrinho),
    # mas a asserção principal é sobre a regra de negócio do próprio
    # DELETE /usuarios/{id}.
    * def usuarioComCarrinho = generador.generarUsuario('true')
    Given path 'usuarios'
    And request usuarioComCarrinho
    When method POST
    Then status 201
    * def idUsuario = response._id

    Given path 'login'
    And request { email: '#(usuarioComCarrinho.email)', password: '#(usuarioComCarrinho.password)' }
    When method POST
    Then status 200
    * def token = response.authorization

    Given path 'produtos'
    And header Authorization = token
    And request { nome: '#(generador.generarNomeCompleto())', preco: 100, descricao: 'Produto de teste Karate', quantidade: 10 }
    When method POST
    Then status 201
    * def idProduto = response._id

    Given path 'carrinhos'
    And header Authorization = token
    And request { produtos: [{ idProduto: '#(idProduto)', quantidade: 1 }] }
    When method POST
    Then status 201

    Given path 'usuarios', idUsuario
    And header Authorization = token
    When method DELETE
    Then status 400
    And match response.message == 'Não é permitido excluir usuário com carrinho cadastrado'
    And match response.idCarrinho == '#string'
