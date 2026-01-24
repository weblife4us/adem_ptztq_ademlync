# 01 - Обзор проекта AdEMLync

## Общее описание

**AdEMLync** - мобильное приложение на Flutter/Dart для работы с газоизмерительными устройствами AdEM (Advanced Electronic Meter).

## Структура проекта

```
ademlync/
+-- ademlync/               # Основное Flutter приложение (UI)
|   +-- lib/
|   |   +-- main.dart           # Точка входа
|   |   +-- chore/              # Bloc, роутинг
|   |   +-- features/           # Экраны и функционал (66 файлов)
|   |   +-- utils/              # Утилиты, виджеты, контроллеры
|   +-- assets/                 # Ресурсы (SVG, PNG)
|   +-- android/                # Android платформа
|   +-- ios/                    # iOS платформа
|
+-- packages/
    +-- ademlync_device/        # Пакет коммуникации с устройствами
    |   +-- controllers/
    |   |   +-- adem_manager.dart              # Главный менеджер
    |   |   +-- bluetooth_connection_manager.dart  # BLE соединение
    |   |   +-- communication_manager.dart     # Протокол обмена
    |   |   +-- command_builder.dart           # Построитель команд
    |   +-- models/             # Модели данных устройства
    |   +-- utils/              # Константы, парсеры, enum
    |
    +-- ademlync_cloud/         # Пакет облачной интеграции
        +-- controllers/
        |   +-- cloud_manager.dart    # Менеджер облака
        |   +-- file_manager.dart     # Работа с файлами
        |   +-- user_manager.dart     # Управление пользователями
        +-- utils/
            +-- api_helper.dart       # HTTP запросы к AWS
```

## Основные технологии

```
Компонент           Технология
------------------------------------------
UI Framework        Flutter/Dart
State Management    BLoC, Provider
Routing             go_router
BLE                 flutter_blue_plus
HTTP Client         Dio
Cloud Backend       AWS API Gateway
```

## Типы устройств AdEM

Приложение поддерживает несколько типов газовых счетчиков:
- **AdEM S** - базовая модель
- **AdEM T** - с температурной компенсацией
- **AdEM TQ** - с компенсацией температуры и расхода
- **AdEM PTZ** - с полной PTZ коррекцией
- **AdEM PTZ-R** - PTZ с расширенными функциями
- **Universal T** - универсальная модель

## Dongles (BLE мосты)

Для связи с устройствами используются два типа адаптеров:
1. **AdEM Key (Dragonfly)** - до 128 байт на пакет
2. **Air Console** - до 20 байт на пакет

## Точка входа приложения

Файл: `ademlync/lib/main.dart`

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([...]);
  runApp(ChangeNotifierProvider<AppStateNotifier>(...));
}
```
