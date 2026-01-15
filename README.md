# SplitWithMe

Aplicación móvil para gestionar y dividir gastos compartidos con amigos.

## Características

- Gestión de gastos compartidos
- Gestión de amigos
- Diseño adaptativo (teléfonos y tablets)
- Manejo robusto de errores
- Arquitectura Provider
- Material Design 3

## Arquitectura

- **Patrón**: Provider para gestión de estado
- **Capas**: Models → Repositories → Providers → Screens
- **Servicios**: API Service para comunicación HTTP
- **Utilidades**: Sistema de excepciones personalizadas, verificación de conectividad

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

## Instalación

1. Clona el repositorio
2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura el soporte para la plataforma deseada:
```bash
# Linux
flutter create --platforms=linux .

# Android
flutter create --platforms=android .

# iOS
flutter create --platforms=ios .
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Dependencias

- `provider`: Gestión de estado
- `http`: Cliente HTTP
- `connectivity_plus`: Verificación de conectividad
- `intl`: Internacionalización y formato de fechas/números

## Estructura del proyecto

```
lib/
├── main.dart
├── models/
│   ├── expense.dart
│   └── friend.dart
├── providers/
│   ├── expense_provider.dart
│   └── friend_provider.dart
├── repositories/
│   ├── expense_repository.dart
│   └── friend_repository.dart
├── screens/
│   ├── home_screen.dart
│   ├── expenses_screen.dart
│   ├── friends_screen.dart
│   ├── add_expense_screen.dart
│   └── add_friend_screen.dart
├── services/
│   └── api_service.dart
└── utils/
    ├── exceptions.dart
    └── connectivity_helper.dart
