MoodWave / Fonn v2.0 - Diario de Emociones y Analitica de Patrones

MoodWave (Fonn) es una aplicacion multiplataforma desarrollada en Flutter (Dart) que evoluciona el registro diario de emociones hacia una plataforma avanzada de analitica de datos personales[cite: 1, 20]. La aplicacion ayuda a descubrir patrones de estado de animo y energia relacionandolos con las actividades diarias de forma honesta, transparente y etica, evitando diagnosticos medicos o afirmaciones de causalidad sin fundamento[cite: 17, 19].

PROYECTO ACADEMICO
Institucion: Instituto Politecnico Nacional - UPIIT
Materia: Programacion de Dispositivos Moviles
Desarrollo: Cristian Leal Rivera
Ano: 2026 - Etapa 2 (Incremento 2)


CARACTERISTICAS PRINCIPALES

1. NUCLEO DE ANALITICA Y ESTADISTICA (NIVEL 1)
- Estadisticas Emocionales: Calculo de promedio, mediana, moda, desviacion estandar (sigma) y racha de dias consecutivos[cite: 17].
- Tendencias Visuales: Grafica de linea interactiva con media movil para visualizar la evolucion del animo en el tiempo[cite: 17].
- Asociacion Actividades vs Animo: Analisis cuantitativo del impacto de cada actividad mostrando el tamano de muestra (n) y el tamano del efecto mediante Cohen's d[cite: 17].
- Generador de Datos Sinteticos: Herramienta integrada para cargar 90 dias de datos sinteticos con patrones controlados para pruebas de motor[cite: 17].
- Lenguaje Responsable: Descripciones redactadas bajo el principio de correlacion y no causalidad[cite: 17].

2. FUNCIONALIDADES AVANZADAS (NIVEL 2)
- Reportes PDF Ejecutivos: Generacion e impresion automatica de informes mensuales con graficos de tendencia, tablas y resumenes[cite: 18].
- Respaldo y Cifrado AES-256: Exportacion e importacion de la base de datos cifrada en Base64 protegida por contrasena[cite: 18].
- Persistencia de Recordatorios: Configuracion de notificaciones diarias guardadas en preferencias locales[cite: 18].
- Control de Edicion por Fecha: Bloqueo de modificacion para dias pasados o futuros, permitiendo unicidad en el registro del dia actual.

3. INTELIGENCIA DE PATRONES (NIVEL 3 - IA)
- Tipologia de Dias (Clustering K-Means): Agrupamiento automatico de jornadas segun energia y actividades (Dias de Alta Vitalidad vs Dias de Recuperacion)[cite: 18].
- Recomendaciones Personalizadas: Sugerencias cuantitativas de actividades basadas en el incremento esperado respecto a la linea base con intervalos de confianza del 95% (95% CI)[cite: 18].
- Procesamiento Local: Todos los algoritmos de IA y analisis se ejecutan 100% de manera local en el dispositivo garantizando privacidad total[cite: 19].

4. ETICA Y SEGURIDAD TRANSVERSAL
- Aviso Medico Obligatorio: Banner visible recordando que la app no sustituye la atencion profesional de salud mental[cite: 19].
- Protocolo de Riesgo Emocional: Deteccion de malestar sostenido que despliega recursos de ayuda y lineas de asistencia gratuita[cite: 19].
- Candado de Seguridad: Acceso protegido por PIN de 4 digitos y autenticacion biometrica (huella dactilar / rostro) mediante local_auth[cite: 20].


REQUISITOS DEL SISTEMA
- Flutter SDK 3.x o superior
- Dart 3.x o superior
- Android SDK 21 o superior (para ejecucion en Android)
- Linux Desktop con librerias GTK y SQLite (clang, cmake, ninja-build, pkg-config, libgtk-3-dev, libsqlite3-dev)


ESTRUCTURA DEL PROYECTO
moodwave_flutter/
├── android/
├── linux/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── analytics/
    │   ├── analytics_engine.dart
    │   └── ai_clustering_engine.dart
    ├── data/
    │   ├── database_helper.dart
    │   └── prefs_manager.dart
    ├── models/
    │   ├── mood_entry.dart
    │   └── mood_level.dart
    ├── providers/
    │   └── mood_provider.dart
    └── ui/
        ├── components/
        │   └── common_widgets.dart
        └── screens/
            ├── ai_insights_screen.dart
            ├── analytics_screen.dart
            ├── backup_screen.dart
            ├── calendar_screen.dart
            ├── credits_screen.dart
            ├── home_screen.dart
            ├── lock_screen.dart
            ├── main_navigation_screen.dart
            ├── new_entry_screen.dart
            ├── pin_change_screen.dart
            ├── profile_screen.dart
            ├── reminders_screen.dart
            ├── reports_screen.dart
            └── settings_screen.dart


INSTRUCCIONES DE EJECUCION

1. Clonar el repositorio e instalar dependencias:
   flutter pub get

2. Ejecutar en Linux Desktop:
   flutter run -d linux

3. Ejecutar en Dispositivo o Emulador Android:
   flutter run


LICENCIA Y CREDITOS
Desarrollado para el Instituto Politecnico Nacional (UPIIT) por Cristian Leal Rivera. Todos los derechos reservados 2026.
