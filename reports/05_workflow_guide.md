# 05 - Руководство по работе с проектом

## Что нужно для разработки

### Требования
- Flutter SDK (версия согласно pubspec.yaml)
- Dart SDK
- Android Studio / VS Code с Flutter плагинами
- Реальное устройство с BLE для тестирования (эмулятор не поддерживает BLE)

### Установка зависимостей

```bash
# В корне проекта
cd ademlync
flutter pub get

# В пакетах
cd packages/ademlync_device
flutter pub get

cd packages/ademlync_cloud
flutter pub get
```

## Архитектура приложения

### Слои

1. **UI Layer** (`ademlync/lib/features/`) - экраны и виджеты
2. **Business Logic** (`ademlync/lib/chore/`) - BLoC состояния
3. **Device Layer** (`packages/ademlync_device/`) - протокол устройства
4. **Cloud Layer** (`packages/ademlync_cloud/`) - облачное API

### Ключевые Singleton

```dart
AdemManager()                  // Управление устройством
BluetoothConnectionManager()   // BLE соединение
CloudManager()                 // Облачные операции
CacheManager()                 // Кэш конфигурации
```

## Процесс подключения к устройству

```
1. Сканирование BLE устройств
   BluetoothConnectionManager.startDeviceScan()

2. Подключение к выбранному устройству
   BluetoothConnectionManager.connect(device)

3. Инициализация связи с AdEM
   AdemManager.fetchAdem()
   +-- wakeUp()      // Пробуждение
   +-- connect()     // Авторизация
   +-- read(...)     // Чтение параметров
   +-- disconnect()  // Завершение

4. Работа с данными
   read(), write(), readLogs()

5. Отключение
   BluetoothConnectionManager.disconnect()
```

## Тестирование

### Unit тесты

```bash
cd packages/ademlync_device
flutter test
```

Доступные тесты:
- `aga8_calculation_test.dart` - AGA8 расчеты
- `crc_calculation_test.dart` - CRC вычисления
- `firmware_version_test.dart` - Версии прошивки
- `serial_number_part_2_test.dart` - Серийные номера
- `super_access_code_test.dart` - Коды доступа

## Как мы будем взаимодействовать

### Мои действия
- Отвечаю на русском языке
- Код и комментарии пишу на английском
- Отчеты сохраняю в `reports/`
- Не коммичу без вашего запроса
- Не использую ANSI коды и Unicode декор

### Для анализа/изменений
1. Укажите конкретный файл или функционал
2. Опишите желаемое поведение
3. Я проанализирую и предложу решение

### Для отчетов
- Запросите отчет, укажу номер (06, 07...)
- Сохраню в `reports/`

### Для тестов
- C, Python, PowerShell, Batch файлы
- Могу создать тесткейсы по запросу

## Важные файлы для изучения

```
Файл                                         Назначение
---------------------------------------------------------------------
ademlync/lib/main.dart                       Точка входа
ademlync_device/.../adem_manager.dart        Логика устройства
ademlync_device/.../communication_manager.dart   BLE протокол
ademlync_cloud/.../cloud_manager.dart        Облачные операции
ademlync_device/lib/utils/constants.dart     Все константы
ademlync_device/.../communication_enums.dart Протоколы и коды
```
