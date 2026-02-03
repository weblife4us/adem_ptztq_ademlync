# AdEMLync PowerShell Scripts

PowerShell скрипты для работы с проектом AdEMLync.

## Быстрый старт

```powershell
# Полный старт (установка + эмулятор + приложение)
.\quick-start.ps1

# Или по отдельности:
.\run-emulator.ps1                       # Запустить эмулятор
.\run-app.ps1                            # Запустить приложение
```

## Список скриптов

| Скрипт               | Описание                               |
|----------------------|----------------------------------------|
| `run-emulator.ps1`   | Запуск Android эмулятора               |
| `run-app.ps1`        | Запуск приложения                      |
| `quick-start.ps1`    | Полный запуск (deps + emulator + app)  |
| `install-deps.ps1`   | Установка зависимостей                 |
| `build-apk.ps1`      | Сборка APK/AAB                         |
| `clean-project.ps1`  | Очистка проекта                        |
| `generate-code.ps1`  | Генерация кода (build_runner)          |
| `doctor.ps1`         | Flutter doctor                         |
| `test.ps1`           | Запуск тестов                          |

## Использование

### run-emulator.ps1

```powershell
.\run-emulator.ps1                       # Запустить Pixel_9_Pro_XL
.\run-emulator.ps1 -EmulatorName "Pixel" # Другой эмулятор
.\run-emulator.ps1 -List                 # Список эмуляторов
.\run-emulator.ps1 -ColdBoot             # Холодный запуск
```

### run-app.ps1

```powershell
.\run-app.ps1                            # Авто-определение эмулятора
.\run-app.ps1 -Device "emulator-5554"    # Конкретное устройство
.\run-app.ps1 -Web                       # Запуск в Chrome
.\run-app.ps1 -Windows                   # Запуск на Windows
.\run-app.ps1 -Release                   # Release режим
.\run-app.ps1 -ListDevices               # Список устройств
```

### quick-start.ps1

```powershell
.\quick-start.ps1                        # Полный запуск
.\quick-start.ps1 -SkipEmulator          # Без эмулятора
.\quick-start.ps1 -Web                   # Запуск в Chrome
.\quick-start.ps1 -Windows               # Запуск на Windows
.\quick-start.ps1 -Log                   # Сохранить вывод в лог-файл
.\quick-start.ps1 -Clean                 # Очистить проект перед сборкой
.\quick-start.ps1 -Clean -Log            # Полная очистка с логированием
```

### flutter_clean_build.ps1

Используется при ошибках Kotlin incremental cache.

```powershell
.\flutter_clean_build.ps1                # Полная очистка + сборка
.\flutter_clean_build.ps1 -Log           # С сохранением лога
.\flutter_clean_build.ps1 -NoBuild       # Только очистка, без сборки
```

### install-deps.ps1

```powershell
.\install-deps.ps1                       # Установить зависимости
.\install-deps.ps1 -Clean                # Очистить + установить
```

### build-apk.ps1

```powershell
.\build-apk.ps1                          # Debug APK
.\build-apk.ps1 -Release                 # Release APK
.\build-apk.ps1 -Bundle                  # App Bundle (.aab)
.\build-apk.ps1 -Split                   # Раздельные APK по архитектуре
.\build-apk.ps1 -Open                    # Открыть папку после сборки
```

### clean-project.ps1

```powershell
.\clean-project.ps1                      # Обычная очистка
.\clean-project.ps1 -Deep                # + удалить lock и generated
```

### generate-code.ps1

```powershell
.\generate-code.ps1                      # Однократная генерация
.\generate-code.ps1 -Watch               # Режим наблюдения
.\generate-code.ps1 -Delete              # Удалять конфликтующие файлы
```

### doctor.ps1

```powershell
.\doctor.ps1                             # Базовая проверка
.\doctor.ps1 -Verbose                    # Подробный вывод
.\doctor.ps1 -Licenses                   # Принять Android лицензии
.\doctor.ps1 -Upgrade                    # Обновить Flutter
```

### test.ps1

```powershell
.\test.ps1                               # Все тесты
.\test.ps1 -Coverage                     # С покрытием
.\test.ps1 -Filter "crc"                 # Фильтр по имени
```

### setup-env.ps1

```powershell
.\setup-env.ps1                          # Настройка текущей сессии
.\setup-env.ps1 -Permanent               # Добавить в системный PATH
.\setup-env.ps1 -Diagnose                # Полная диагностика
```

## Автоматическое определение путей

Скрипты автоматически ищут Flutter и Android SDK в стандартных местах:

| Компонент   | Пути поиска                                            |
|-------------|--------------------------------------------------------|
| Flutter     | `C:\flutter\bin`                                       |
|             | `C:\src\flutter\bin`                                   |
|             | `%USERPROFILE%\flutter\bin`                            |
|             | `%LOCALAPPDATA%\flutter\bin`                           |
|             | `D:\flutter\bin`                                       |
| Android SDK | `%ANDROID_HOME%` (переменная окружения)                |
|             | `%ANDROID_SDK_ROOT%` (переменная окружения)            |
|             | `%LOCALAPPDATA%\Android\Sdk`                           |
|             | `%USERPROFILE%\AppData\Local\Android\Sdk`              |
| AVD         | `%USERPROFILE%\.android\avd`                           |

## Первый запуск на новом компьютере

| Шаг | Действие                                                    |
|-----|-------------------------------------------------------------|
| 1   | Установите Flutter                                          |
| 2   | Установите Android Studio                                   |
| 3   | Создайте AVD: Android Studio > Tools > Device Manager       |
| 4   | Запустите диагностику: `.\setup-env.ps1 -Diagnose`          |
| 5   | Если все найдено: `.\quick-start.ps1`                       |
| 6   | Если AVD не найден: укажите вручную (см. ниже)              |

```powershell
.\run-emulator.ps1 -List                 # Посмотреть список AVD
.\quick-start.ps1 -AVD "Pixel_8_API_34"  # Указать конкретный AVD
```

## Устранение ошибок Kotlin

### Ошибка "this and base files have different roots"

Эта ошибка возникает на Windows когда проект на диске D:\, а Pub Cache на C:\.

| Решение   | Описание                                                   |
|-----------|------------------------------------------------------------|
| Решение 1 | Автоматически применено в `android/gradle.properties`      |
| Решение 2 | Полная очистка: `.\flutter_clean_build.ps1 -Log`           |
| Решение 3 | Переместить Pub Cache на тот же диск (см. ниже)            |

**Решение 1** - уже применено:

```properties
# android/gradle.properties
kotlin.incremental=false
kotlin.incremental.java=false
```

**Решение 2** - полная очистка:

```powershell
.\flutter_clean_build.ps1 -Log           # Удалит все кэши Gradle/Kotlin
```

**Решение 3** - переместить Pub Cache:

```powershell
$env:PUB_CACHE = "D:\PubCache"
[Environment]::SetEnvironmentVariable("PUB_CACHE", "D:\PubCache", "User")
flutter pub cache repair
```

## Логирование

Для анализа проблем сборки используйте флаг `-Log`:

```powershell
.\quick-start.ps1 -Log                   # Лог quick-start
.\flutter_clean_build.ps1 -Log           # Лог clean build
```

| Параметр         | Описание                                      |
|------------------|-----------------------------------------------|
| Папка логов      | `scripts/logs/`                               |
| Формат имени     | `build_YYYY-MM-DD_HH-mm-ss.log`               |
| Содержимое       | Полный вывод PowerShell transcript            |

## Примечания

| Функция                      | Описание                                      |
|------------------------------|-----------------------------------------------|
| Авто-поиск Flutter           | Скрипты находят Flutter автоматически         |
| Авто-поиск Android SDK       | Скрипты находят SDK автоматически             |
| Авто-определение AVD         | Из папки `%USERPROFILE%\.android\avd`         |
| Авто-определение эмулятора   | `run-app.ps1` находит запущенный эмулятор     |
| Защита от дубликатов         | `run-emulator.ps1` не запускает повторно      |
| Диагностика                  | `.\setup-env.ps1 -Diagnose`                   |
| Логи сборки                  | Сохраняются при использовании `-Log`          |
