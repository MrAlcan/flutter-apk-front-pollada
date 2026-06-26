# Mundial Polla — Frontend (Flutter / Android)

App móvil de la polla mundialista por jornadas: cada día con partidos se abre
una jornada; para participar hay que pronosticar **todos** los partidos del
día antes del cierre (1 minuto antes del primer partido). Los pronósticos son
inmutables y privados hasta que termina el último partido del día; entonces se
revelan los de todos los participantes y los ganadores de la jornada. Acertar
el resultado general suma 1 punto y el marcador exacto 3 (configurables en el
backend). El usuario administrador carga los resultados desde la propia app
—no se consume ninguna API externa— y, en fase de grupos, los clasificados a
las fases siguientes se calculan automáticamente.
Stack: **Flutter · Riverpod · dio · go_router · flutter_animate**.

## Inicializar el repositorio

```bash
cd frontend
git init -b main          # (ya inicializado si clonaste este repo)
flutter pub get
```

Requisitos: Flutter 3.44+ y, para compilar Android, JDK 17 + Android SDK
(`flutter doctor` te dice qué falta).

## Ejecutar en desarrollo

Con el backend levantado (`../run.sh` desde la raíz del monorepo):

```bash
flutter emulators                      # lista tus emuladores
flutter emulators --launch <id>        # o conecta un dispositivo con USB debugging
flutter run
```

* **Emulador**: funciona sin configurar nada — la app apunta a
  `http://10.0.2.2:8000`, que es el localhost de tu máquina visto desde el
  emulador Android.
* **Dispositivo físico**: tu teléfono debe alcanzar al backend por la red
  local; pasa la IP de tu PC:

```bash
flutter run --dart-define=API_BASE_URL=http://<IP-de-tu-PC>:8000
```

> En Windows + WSL2, usa la IP LAN de Windows (`ipconfig` → IPv4) y asegúrate
> de que el firewall permite el puerto 8000 (Docker Desktop ya lo publica en
> el host).

## Generar el APK para instalar en un dispositivo

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://<IP-de-tu-PC>:8000
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Cópialo al
teléfono (o `adb install app-release.apk`) y habilita "instalar apps de
orígenes desconocidos".

Notas:

* El release usa la **firma de debug** por defecto (suficiente para pruebas).
  Para distribuir en Play Store crea tu keystore y configúralo en
  `android/app/build.gradle.kts` siguiendo
  [la guía oficial](https://docs.flutter.dev/deployment/android#sign-the-app).
* El manifest permite tráfico HTTP (`usesCleartextTraffic`) para desarrollo;
  en producción sirve la API tras TLS y elimina esa bandera.
* `--split-per-abi` genera APKs más pequeños por arquitectura si lo prefieres.

## Calidad

```bash
flutter analyze   # linting estático
flutter test      # widget tests (login + leaderboard animado)
```

## Arquitectura

```
lib/
├── core/                  # config (URL por --dart-define), tema, dio+JWT,
│   └── ...                # almacenamiento seguro, router, utilidades de fecha
└── features/
    ├── auth/              # login/registro (JWT) con bandera is_admin
    ├── pools/             # jornadas diarias de apuestas
    │   ├── domain/        # jornada, partido, pronóstico, reveal, tabla
    │   ├── data/          # REST (dio): días, participación, reveal, tabla
    │   └── presentation/  # Hoy, Historial, detalle de jornada,
    │                      # formulario sellado de pronósticos, clasificación
    └── admin/             # panel del administrador: carga de resultados
                           # (fase de grupos recalcula clasificados en backend)
```
