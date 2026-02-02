# AdEMLync PowerShell Scripts

PowerShell скрипты для работы с проектом AdEMLync.

## Быстрый старт

```powershell
# Полный старт (установка + эмулятор + приложение)
.\quick-start.ps1

# Или по отдельности:
.\run-emulator.ps1    # Запустить эмулятор
.\run-app.ps1         # Запустить приложение
```

## Список скриптов

| Скрипт | Описание |
|--------|----------|
| `run-emulator.ps1` | Запуск Android эмулятора |
| `run-app.ps1` | Запуск приложения |
| `quick-start.ps1` | Полный запуск (deps + emulator + app) |
| `install-deps.ps1` | Установка зависимостей |
| `build-apk.ps1` | Сборка APK/AAB |
| `clean-project.ps1` | Очистка проекта |
| `generate-code.ps1` | Генерация кода (build_runner) |
| `doctor.ps1` | Flutter doctor |
| `test.ps1` | Запуск тестов |

## Использование

### run-emulator.ps1
```powershell
.\run-emulator.ps1                        # Запустить Pixel_9_Pro_XL
.\run-emulator.ps1 -EmulatorName "Pixel_8"  # Другой эмулятор
.\run-emulator.ps1 -List                  # Список эмуляторов
.\run-emulator.ps1 -ColdBoot              # Холодный запуск
```

### run-app.ps1
```powershell
.\run-app.ps1                 # Авто-определение эмулятора
.\run-app.ps1 -Device "emulator-5554"  # Конкретное устройство
.\run-app.ps1 -Web            # Запуск в Chrome
.\run-app.ps1 -Windows        # Запуск на Windows
.\run-app.ps1 -Release        # Release режим
.\run-app.ps1 -ListDevices    # Список устройств
```

### quick-start.ps1
```powershell
.\quick-start.ps1             # Полный запуск
.\quick-start.ps1 -SkipEmulator  # Без эмулятора
.\quick-start.ps1 -Web        # Запуск в Chrome
.\quick-start.ps1 -Windows    # Запуск на Windows
```

### install-deps.ps1
```powershell
.\install-deps.ps1            # Установить зависимости
.\install-deps.ps1 -Clean     # Очистить + установить
```

### build-apk.ps1
```powershell
.\build-apk.ps1               # Debug APK
.\build-apk.ps1 -Release      # Release APK
.\build-apk.ps1 -Bundle       # App Bundle (.aab)
.\build-apk.ps1 -Split        # Раздельные APK по архитектуре
.\build-apk.ps1 -Open         # Открыть папку после сборки
```

### clean-project.ps1
```powershell
.\clean-project.ps1           # Обычная очистка
.\clean-project.ps1 -Deep     # + удалить lock и generated файлы
```

### generate-code.ps1
```powershell
.\generate-code.ps1           # Однократная генерация
.\generate-code.ps1 -Watch    # Режим наблюдения
.\generate-code.ps1 -Delete   # Удалять конфликтующие файлы
```

### doctor.ps1
```powershell
.\doctor.ps1                  # Базовая проверка
.\doctor.ps1 -Verbose         # Подробный вывод
.\doctor.ps1 -Licenses        # Принять Android лицензии
.\doctor.ps1 -Upgrade         # Обновить Flutter
```

### test.ps1
```powershell
.\test.ps1                    # Все тесты
.\test.ps1 -Coverage          # С покрытием
.\test.ps1 -Filter "crc"      # Фильтр по имени
```

## Примечания

- Скрипты автоматически добавляют Flutter в PATH (`C:\flutter\bin`)
- `run-app.ps1` автоматически определяет запущенный эмулятор
- `run-emulator.ps1` не запускает повторно если эмулятор уже работает
