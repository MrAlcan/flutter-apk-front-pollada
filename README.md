# Mundial Polla — Frontend (Flutter / Android)

App móvil de la quiniela: login/registro con JWT, lobby de partidos con
marcadores en vivo, pronósticos vía bottom-sheet y tabla de clasificación que
se reordena con animaciones en tiempo real (WebSocket con reconexión
automática). Stack: **Flutter · Riverpod · dio · go_router · flutter_animate**.

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
flutter run \
  --dart-define=API_BASE_URL=http://<IP-de-tu-PC>:8000 \
  --dart-define=WS_LIVE_URL=ws://<IP-de-tu-PC>:8000/ws/live
```

> En Windows + WSL2, usa la IP LAN de Windows (`ipconfig` → IPv4) y asegúrate
> de que el firewall permite el puerto 8000 (Docker Desktop ya lo publica en
> el host).

## Generar el APK para instalar en un dispositivo

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://<IP-de-tu-PC>:8000 \
  --dart-define=WS_LIVE_URL=ws://<IP-de-tu-PC>:8000/ws/live
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
dart run tool/ws_probe.dart 30   # sonda del WebSocket contra el backend local
```

## Arquitectura

```
lib/
├── core/                  # config (URLs por --dart-define), tema, dio+JWT,
│   └── ...                # almacenamiento seguro, router con redirect por sesión
└── features/
    ├── auth/              # login/registro: domain ⇆ data ⇆ presentation
    └── live/              # partidos, pronósticos y tabla en tiempo real
        ├── domain/        # entidades y contrato LiveRepository
        ├── data/          # REST (dio) + WebSocket con backoff exponencial
        └── presentation/  # lobby, leaderboard animado, bottom-sheet, Riverpod
```
