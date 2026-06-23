package com.serverest.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Punto de entrada para ejecutar la suite de pruebas de la API de Usuarios
 * de ServeRest (https://serverest.dev).
 *
 * Ejecutar TODA la suite (todos los .feature dentro de classpath:usuarios):
 *   mvn test
 *
 * Ejecutar solo un feature puntual, por ejemplo solo el de creacion:
 *   mvn test -Dkarate.options="classpath:usuarios/registro-usuario.feature"
 *
 * Ejecutar solo escenarios con una etiqueta especifica:
 *   mvn test -Dkarate.options="--tags @negativo"
 *   mvn test -Dkarate.options="--tags @smoke"
 *
 * Ejecutar contra otro ambiente definido en karate-config.js:
 *   mvn test -Dkarate.env=local
 *
 * El reporte HTML se genera en: target/karate-reports/karate-summary.html
 */
class UsuariosRunner {

    @Karate.Test
    Karate testarApiDeUsuarios() {
        return Karate.run("classpath:usuarios");
    }
}
