function fn() {
  var env = karate.env;
  karate.log('karate.env system property fue:', env);

  if (!env) {
    env = 'online';
  }

  var config = {
    env: env,
    baseUrl: 'https://serverest.dev'
  };

  if (env === 'local') {
    // Ambiente local levantado con: npx serverest@latest
    // (ver https://github.com/ServeRest/ServeRest)
    config.baseUrl = 'http://localhost:3000';
  }

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 15000);
  karate.configure('headers', { 'Content-Type': 'application/json' });

  // Utilidad de generacion de datos de prueba (ver usuarios/utils/generadorDatos.js).
  // Queda disponible como "generador" en todos los .feature de este proyecto.
  config.generador = read('classpath:usuarios/utils/generadorDatos.js');

  karate.log('Ejecutando suite de Usuarios contra:', config.baseUrl);

  return config;
}
