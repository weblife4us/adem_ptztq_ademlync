# Руководство по PowerShell скриптам AdEMLync

## Обзор

Набор PowerShell скриптов для автоматизации разработки Flutter-приложения AdEMLync. Скрипты расположены в директории:

```
d:\cursor\ademlync\ademlync\scripts\
```

## Список скриптов

| Скрипт | Назначение |
|--------|------------|
| `run-emulator.ps1` | Запуск Android эмулятора |
| `run-app.ps1` | Запуск приложения на устройстве |
| `quick-start.ps1` | Полный цикл запуска (зависимости + эмулятор + приложение) |
| `install-deps.ps1` | Установка зависимостей проекта |
| `build-apk.ps1` | Сборка APK/AAB файлов |
| `clean-project.ps1` | Очистка проекта |
| `generate-code.ps1` | Генерация кода (build_runner) |
| `doctor.ps1` | Диагностика Flutter |
| `test.ps1` | Запуск тестов |

---

## Подробное описание скриптов

### run-emulator.ps1

Управление Android эмулятором.

**Использование:**

```powershell
# Запустить эмулятор по умолчанию (Pixel_9_Pro_XL)
.\run-emulator.ps1

# Запустить конкретный эмулятор
.\run-emulator.ps1 -EmulatorName "Pixel_8"

# Показать список доступных эмуляторов
.\run-emulator.ps1 -List

# Холодный запуск (сброс состояния)
.\run-emulator.ps1 -ColdBoot
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-EmulatorName` | string | Имя эмулятора (по умолчанию: Pixel_9_Pro_XL) |
| `-List` | switch | Показать список эмуляторов |
| `-ColdBoot` | switch | Холодный запуск эмулятора |

**Особенности:**
- Автоматически проверяет, запущен ли уже эмулятор
- Ожидает 40 секунд для загрузки эмулятора
- Показывает список подключенных устройств после запуска

---

### run-app.ps1

Запуск приложения на подключенном устройстве или эмуляторе.

**Использование:**

```powershell
# Автоматический выбор устройства (приоритет: Android)
.\run-app.ps1

# Запуск на конкретном устройстве
.\run-app.ps1 -Device "emulator-5554"
.\run-app.ps1 -Device "R5GL11BEDGM"

# Запуск в браузере Chrome
.\run-app.ps1 -Web

# Запуск на Windows
.\run-app.ps1 -Windows

# Release режим
.\run-app.ps1 -Release

# Profile режим (для анализа производительности)
.\run-app.ps1 -Profile

# Показать список устройств
.\run-app.ps1 -ListDevices
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Device` | string | ID устройства (emulator-5554, R5GL11BEDGM и т.д.) |
| `-Web` | switch | Запуск в Chrome |
| `-Windows` | switch | Запуск на Windows |
| `-Release` | switch | Сборка в Release режиме |
| `-Profile` | switch | Сборка в Profile режиме |
| `-ListDevices` | switch | Показать подключенные устройства |

**Особенности:**
- Автоматически определяет Android эмулятор или устройство
- Поддерживает все режимы сборки Flutter

---

### quick-start.ps1

Полный цикл запуска проекта: установка зависимостей, запуск эмулятора и приложения.

**Использование:**

```powershell
# Полный запуск
.\quick-start.ps1

# Без эмулятора (для физического устройства)
.\quick-start.ps1 -SkipEmulator

# Запуск в Chrome
.\quick-start.ps1 -Web

# Запуск на Windows
.\quick-start.ps1 -Windows
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-SkipEmulator` | switch | Пропустить запуск эмулятора |
| `-Web` | switch | Запуск в Chrome |
| `-Windows` | switch | Запуск на Windows |

**Этапы выполнения:**
1. Проверка Flutter (`flutter --version`)
2. Установка зависимостей (`flutter pub get`)
3. Запуск эмулятора (если не указан `-SkipEmulator`)
4. Запуск приложения

---

### install-deps.ps1

Установка зависимостей для всех пакетов проекта.

**Использование:**

```powershell
# Установить зависимости
.\install-deps.ps1

# Очистить и установить заново
.\install-deps.ps1 -Clean
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Clean` | switch | Выполнить `flutter clean` перед установкой |

**Устанавливает зависимости для:**
1. Основного приложения (`ademlync/`)
2. Пакета устройств (`packages/ademlync_device/`)
3. Облачного пакета (`packages/ademlync_cloud/`)

---

### build-apk.ps1

Сборка Android пакетов (APK или App Bundle).

**Использование:**

```powershell
# Debug APK
.\build-apk.ps1

# Release APK
.\build-apk.ps1 -Release

# App Bundle (.aab) для Google Play
.\build-apk.ps1 -Bundle -Release

# Раздельные APK по архитектуре процессора
.\build-apk.ps1 -Release -Split

# Открыть папку с результатом
.\build-apk.ps1 -Release -Open
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Release` | switch | Release сборка |
| `-Bundle` | switch | Собрать App Bundle вместо APK |
| `-Split` | switch | Раздельные APK по архитектуре |
| `-Open` | switch | Открыть папку после сборки |

**Расположение результатов:**
- APK: `build\app\outputs\flutter-apk\`
- AAB: `build\app\outputs\bundle\`

---

### clean-project.ps1

Очистка проекта от сборочных артефактов.

**Использование:**

```powershell
# Обычная очистка
.\clean-project.ps1

# Глубокая очистка (+ удаление lock файлов и сгенерированного кода)
.\clean-project.ps1 -Deep
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Deep` | switch | Удалить pubspec.lock и *.g.dart файлы |

**Очищает:**
- Основное приложение
- ademlync_device
- ademlync_cloud

---

### generate-code.ps1

Генерация кода с помощью build_runner (для json_serializable и др.).

**Использование:**

```powershell
# Однократная генерация
.\generate-code.ps1

# Режим наблюдения (автоматическая перегенерация при изменениях)
.\generate-code.ps1 -Watch

# Удалять конфликтующие файлы
.\generate-code.ps1 -Delete
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Watch` | switch | Режим наблюдения |
| `-Delete` | switch | Удалять конфликтующие выходные файлы |

**Примечание:** Генерирует `*.g.dart` файлы в пакете `ademlync_cloud`.

---

### doctor.ps1

Диагностика и обслуживание Flutter.

**Использование:**

```powershell
# Базовая диагностика
.\doctor.ps1

# Подробный вывод
.\doctor.ps1 -Verbose

# Принять Android лицензии
.\doctor.ps1 -Licenses

# Обновить Flutter
.\doctor.ps1 -Upgrade
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Verbose` | switch | Подробный вывод (`flutter doctor -v`) |
| `-Licenses` | switch | Принять Android лицензии |
| `-Upgrade` | switch | Обновить Flutter |

---

### test.ps1

Запуск тестов для всех пакетов проекта.

**Использование:**

```powershell
# Все тесты
.\test.ps1

# С покрытием кода
.\test.ps1 -Coverage

# Фильтр по имени теста
.\test.ps1 -Filter "crc"
```

**Параметры:**

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Coverage` | switch | Генерировать отчет о покрытии |
| `-Filter` | string | Фильтр по имени теста |

**Тестирует:**
1. Основное приложение
2. ademlync_device
3. ademlync_cloud

---

## Типичные сценарии использования

### Первый запуск проекта

```powershell
cd d:\cursor\ademlync\ademlync\scripts

# Вариант 1: Полный автоматический запуск
.\quick-start.ps1

# Вариант 2: Пошаговый запуск
.\install-deps.ps1
.\run-emulator.ps1
.\run-app.ps1
```

### Запуск на физическом устройстве (планшет/телефон)

1. Подключить устройство по USB
2. Включить USB-отладку (Настройки → Для разработчиков → USB-отладка)
3. Отключить Auto Blocker (для Samsung)
4. Разрешить отладку на устройстве

```powershell
# Проверить подключение
.\run-app.ps1 -ListDevices

# Запустить (автоматически найдет устройство)
.\run-app.ps1
```

### Сборка для публикации

```powershell
# Очистить проект
.\clean-project.ps1 -Deep

# Установить зависимости
.\install-deps.ps1

# Сгенерировать код
.\generate-code.ps1 -Delete

# Собрать Release APK
.\build-apk.ps1 -Release -Open

# Или App Bundle для Google Play
.\build-apk.ps1 -Bundle -Release -Open
```

### Разработка с автоматической перегенерацией кода

```powershell
# В первом терминале - наблюдение за изменениями
.\generate-code.ps1 -Watch

# Во втором терминале - запуск приложения
.\run-app.ps1
```

### Диагностика проблем

```powershell
# Проверить состояние Flutter
.\doctor.ps1 -Verbose

# Если есть проблемы с лицензиями
.\doctor.ps1 -Licenses

# Обновить Flutter до последней версии
.\doctor.ps1 -Upgrade
```

---

## Требования

### Системные требования

- Windows 10/11
- PowerShell 5.1 или выше
- Flutter SDK (установлен в `C:\flutter\`)
- Android Studio (для эмулятора и SDK)

### Настройка Flutter PATH

Скрипты автоматически добавляют Flutter в PATH:

```powershell
$env:Path = "C:\flutter\bin;$env:Path"
```

Если Flutter установлен в другом месте, измените эту строку в начале каждого скрипта.

---

## Структура проекта

```
d:\cursor\ademlync\
├── ademlync\                    # Главное Flutter приложение
│   ├── lib\                     # Исходный код
│   ├── android\                 # Android конфигурация
│   ├── pubspec.yaml             # Зависимости
│   └── scripts\                 # PowerShell скрипты
│       ├── run-emulator.ps1
│       ├── run-app.ps1
│       ├── quick-start.ps1
│       ├── install-deps.ps1
│       ├── build-apk.ps1
│       ├── clean-project.ps1
│       ├── generate-code.ps1
│       ├── doctor.ps1
│       ├── test.ps1
│       └── README.md
└── packages\
    ├── ademlync_device\         # BLE коммуникация с устройствами
    └── ademlync_cloud\          # Интеграция с AWS облаком
```

---

## Устранение неполадок

### Устройство не видно в списке

1. Проверить USB-отладку на устройстве
2. Отключить Auto Blocker (Samsung)
3. Разрешить отладку при подключении
4. Попробовать другой USB кабель/порт

### Ошибка "flutter is not recognized"

Flutter не в PATH. Скрипты добавляют его автоматически, но можно добавить вручную:

```powershell
$env:Path = "C:\flutter\bin;$env:Path"
```

### Ошибка версии Dart SDK

```powershell
.\doctor.ps1 -Upgrade
```

### Отсутствуют сгенерированные файлы (*.g.dart)

```powershell
.\generate-code.ps1 -Delete
```

### Ошибки Gradle сборки

```powershell
.\clean-project.ps1 -Deep
.\install-deps.ps1
```

---

## Дата создания

Январь 2026

## Версия

1.0
