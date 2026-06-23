/**
 * Utilidades de generacion de datos de prueba para la API de Usuarios.
 *
 * Uso dentro de un .feature:
 *   * def usuario = gerador.gerarUsuario()
 *   * def admin = gerador.gerarUsuario('true')
 *
 * "gerador" ya queda disponible globalmente porque karate-config.js lo
 * registra en la variable de configuracion (config.gerador), pero este
 * archivo tambien puede leerse de forma independiente con:
 *   * def gerador = read('classpath:usuarios/utils/geradorDados.js')
 */
(function () {
  var nombres = [
    'Ana', 'Bruno', 'Carla', 'Diego', 'Elena', 'Fabio', 'Gabriela', 'Hugo',
    'Ines', 'Joao', 'Karina', 'Lucas', 'Marina', 'Nestor', 'Olivia', 'Pedro'
  ];

  var apellidos = [
    'Silva', 'Souza', 'Oliveira', 'Santos', 'Pereira', 'Costa', 'Almeida',
    'Ribeiro', 'Carvalho', 'Gomes', 'Martins', 'Araujo', 'Melo', 'Barros'
  ];

  var caracteresAlfanumericos = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  function elegirAleatorio(lista) {
    return lista[Math.floor(Math.random() * lista.length)];
  }

  function generarNomeCompleto() {
    return elegirAleatorio(nombres) + ' ' + elegirAleatorio(apellidos);
  }

  // Email unico por ejecucion (timestamp + sufijo aleatorio) para evitar
  // colisiones de "email ja esta sendo usado" contra la instancia publica
  // compartida de serverest.dev.
  function generarEmail() {
    var timestamp = new Date().getTime();
    var sufijoAleatorio = Math.floor(Math.random() * 1000000);
    return 'karate.teste.' + timestamp + '.' + sufijoAleatorio + '@serverest.com';
  }

  function generarSenha() {
    return 'Karate@' + Math.floor(Math.random() * 1000000);
  }

  // ServeRest exige el string 'true' o 'false' (no booleano, no numero).
  function generarAdministrador() {
    return elegirAleatorio(['true', 'false']);
  }

  /**
   * Genera un objeto de usuario completo y valido para POST/PUT.
   * @param {string} [administrador] 'true' o 'false'. Si se omite, se elige al azar.
   */
  function generarUsuario(administrador) {
    return {
      nome: generarNomeCompleto(),
      email: generarEmail(),
      password: generarSenha(),
      administrador: administrador || generarAdministrador()
    };
  }

  // Id de 16 caracteres alfanumericos: mismo formato que usa ServeRest
  // para sus _id. Util para probar "formato valido pero no encontrado"
  // en GET /usuarios/{id}.
  function generarId16CaracteresAleatorios() {
    var id = '';
    for (var i = 0; i < 16; i++) {
      id += caracteresAlfanumericos.charAt(Math.floor(Math.random() * caracteresAlfanumericos.length));
    }
    return id;
  }

  // Id de longitud arbitraria, util para PUT/DELETE (no exigen el formato
  // de 16 caracteres alfanumericos, a diferencia de GET /usuarios/{id}).
  function generarIdAleatorio() {
    return 'idTeste' + new Date().getTime() + Math.floor(Math.random() * 1000);
  }

  return {
    generarNomeCompleto: generarNomeCompleto,
    generarEmail: generarEmail,
    generarSenha: generarSenha,
    generarAdministrador: generarAdministrador,
    generarUsuario: generarUsuario,
    generarId16CaracteresAleatorios: generarId16CaracteresAleatorios,
    generarIdAleatorio: generarIdAleatorio
  };
})()
