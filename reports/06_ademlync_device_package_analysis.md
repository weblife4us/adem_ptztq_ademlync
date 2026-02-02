# Анализ Flutter-пакета ademlync_device

**Дата создания:** 29 января 2026  
**Версия пакета:** 0.0.1  
**Путь:** `packages/ademlync_device/`

---

## 1. Общая информация

Это **Flutter-пакет** (не самостоятельное приложение), предназначенный для коммуникации с устройствами AdEM (Advanced Electronic Meters) через Bluetooth Low Energy (BLE). Пакет является частью монорепозитория `ademlync`.

### 1.1 Структура пакета

```
ademlync_device/
├── lib/
│   ├── ademlync_device.dart          # Главный экспорт
│   ├── controllers/
│   │   ├── adem_action_helper.dart
│   │   ├── adem_manager.dart         # Главный менеджер устройств
│   │   ├── aga_detail_calculator.dart
│   │   ├── bluetooth_connection_manager.dart  # BLE соединение
│   │   ├── cache_manager.dart        # Кэширование данных
│   │   ├── command_builder.dart      # Построение команд
│   │   └── communication_manager.dart # BLE коммуникация
│   ├── models/
│   │   ├── adem/
│   │   │   ├── adem.dart             # Модель устройства
│   │   │   ├── config_cache.dart     # Кэш конфигурации
│   │   │   ├── measure_cache.dart    # Кэш измерений
│   │   │   └── unit.dart             # Базовый класс
│   │   ├── adem_response.dart        # Ответ от устройства
│   │   ├── aga8_config.dart          # Конфигурация AGA8
│   │   ├── calibration/              # Модели калибровки
│   │   ├── log/                      # Модели логов
│   │   └── modules/                  # Дополнительные модули
│   └── utils/
│       ├── adem_param.dart           # Параметры EEPROM
│       ├── adem_param_enums.dart     # Перечисления
│       ├── communication_enums.dart  # Протокол связи
│       ├── constants.dart            # Константы
│       ├── data_parser.dart          # Парсер данных
│       ├── error_enum.dart           # Типы ошибок
│       ├── functions.dart            # Вспомогательные функции
│       └── log_parser.dart           # Парсер логов
├── test/
│   ├── aga8_calculation_test.dart
│   ├── crc_calculation_test.dart
│   ├── firmware_version_test.dart
│   ├── serial_number_part_2_test.dart
│   └── super_access_code_test.dart
├── pubspec.yaml
└── README.md
```

---

## 2. Установка зависимостей

### 2.1 Команда установки

```bash
# Из корня проекта
cd packages/ademlync_device
flutter pub get
```

### 2.2 Зависимости (pubspec.yaml)

```yaml
dependencies:
  equatable: ^2.0.5       # Сравнение объектов
  flutter:
    sdk: flutter
  intl: any               # Форматирование даты/времени
  flutter_blue_plus: ^1.36.8  # BLE коммуникация

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  test: ^1.25.7

environment:
  sdk: ">=3.10.0 <4.0.0"
  flutter: ">=1.17.0"
```

---

## 3. Использование пакета

Пакет экспортируется как библиотека и подключается в основное приложение:

```dart
import 'package:ademlync_device/ademlync_device.dart';
```

### 3.1 Экспортируемые модули

```dart
library;

export 'controllers/adem_action_helper.dart';
export 'controllers/adem_manager.dart';
export 'controllers/bluetooth_connection_manager.dart';
export 'controllers/command_builder.dart';
export 'controllers/communication_manager.dart';
export 'models/adem/adem.dart';
export 'models/adem_response.dart';
export 'models/aga8_config.dart';
export 'models/calibration/calibration.dart';
export 'models/log/log.dart';
export 'utils/adem_param.dart';
export 'utils/communication_enums.dart';
export 'utils/constants.dart';
export 'utils/data_parser.dart';
export 'utils/error_enum.dart';
export 'utils/functions.dart';
export 'utils/log_parser.dart';
export 'controllers/aga_detail_calculator.dart';
```

---

## 4. Архитектура BLE-коммуникации

### 4.1 Поддерживаемые BLE-донглы

Пакет работает с двумя типами Bluetooth-адаптеров:

#### AdEM Key (Dragonfly)

```
Service UUID:        6e400001-b5a3-f393-e0a9-e50e24dcca9e
Write Characteristic: 6e400002-b5a3-f393-e0a9-e50e24dcca9e
Read Characteristic:  6e400003-b5a3-f393-e0a9-e50e24dcca9e
Max bytes:           128
```

#### Air Console

```
Service UUID:         0f1e4b13-16d2-4396-bf25-000000000000
Write/Read Characteristic: 0f1e4b13-16d2-4396-bf25-000000000001
Max bytes:            20
```

### 4.2 BluetoothConnectionManager

Singleton-класс для управления BLE-соединением:

```dart
class BluetoothConnectionManager {
  // Singleton паттерн
  static final _manager = BluetoothConnectionManager._internal();
  factory BluetoothConnectionManager() => _manager;
  
  // Текущее подключенное устройство
  BluetoothDevice? get connectedDevice;
  
  // Характеристики для чтения/записи
  BluetoothCharacteristic? get readCharacteristic;
  BluetoothCharacteristic? get writeCharacteristic;
  
  // Определение типа донгла
  bool isAirConsole();
  
  // Методы
  Future<void> startDeviceScan();
  Future<void> stopDeviceScan();
  Future<void> connect(BluetoothDevice device);
  Future<void> disconnect();
  Future<int?> fetchBattery();
}
```

### 4.3 Протокол коммуникации

Структура команды:

```
[SOH] + [COMMAND_BYTES] + [CRC16] + [EOT]
 0x01                      4 hex    0x04
```

#### Контрольные символы

| Символ | Байт | Описание |
|--------|------|----------|
| SOH | 0x01 | Start of Header |
| STX | 0x02 | Start of Text |
| ETX | 0x03 | End of Text |
| EOT | 0x04 | End of Transmission |
| ENQ | 0x05 | Enquiry (пробуждение) |
| ACK | 0x06 | Acknowledge |
| RS | 0x1E | Record Separator |

### 4.4 CRC-16-CCITT

Используется для проверки целостности данных:

```dart
String crcCalculation(List<int> bytes) {
  const polynomial = 0x1021;
  const initial = 0x0000;
  int crc = initial & 0xFFFF;

  for (final byte in bytes) {
    crc ^= (byte << 8) & 0xFFFF;
    for (var i = 0; i < 8; ++i) {
      if (crc & 0x8000 != 0) {
        crc = ((crc << 1) ^ polynomial) & 0xFFFF;
      } else {
        crc = (crc << 1) & 0xFFFF;
      }
    }
  }
  return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
}
```

---

## 5. Типы устройств AdEM

Пакет поддерживает 8 типов устройств, определяемых по версии прошивки:

| Тип устройства | Паттерн прошивки | Пример | Последняя цифра |
|----------------|------------------|--------|-----------------|
| AdEM S | `####RS#5` | D050RS15 | 5 |
| AdEM T | `####RT#3` | D020RT03 | 3 |
| AdEM Tq | `####(M\|R)Q#7` | D060MQ47 | 7 |
| Universal T | `###NMT#3` | D05NMT03 | 3 |
| AdEM PTZ | `###XM##4` | D05NM004 | 4 |
| AdEM PTZ-r | `###XM##6` | D05NM006 | 6 |
| AdEM R | (E firmware) | E010RP04 | - |
| AdEM Mi | (E firmware) | E010MP04 | - |

### 5.1 Расшифровка прошивки

```
D050RS15
│││││││└─ Последняя цифра (тип устройства)
││││││└── Revision
│││││└─── S = Basic
││││└──── R = Romet Protocol
│││└───── Minor version (50)
│└─────── Major version (D)
```

### 5.2 AdemType enum

```dart
enum AdemType {
  ademS(3, 'RS', 1, 5),
  ademT(3, 'RT', 1, 3),
  universalT(3, 'MT', 1, 3),
  ademTq(3, '(M|R)Q', 1, 7),
  ademPtz(2, '[NAGS](M|R)', 2, 4),
  ademPtzR(2, '[NAGS](M|R)', 2, 6),
  ademR(2, '[NAGS](M|R)', 2, 6),
  ademMi(2, '[NAGS](M|R)', 2, 6);
  
  // Методы
  bool get isMeterSizeSupported;
  bool isSuperAccessCodeSupported(String firmwareVersion);
  bool isSerialNumberPart2Supported(String firmwareVersion);
  String get noDataSymbol;
}
```

---

## 6. Структура параметров EEPROM

Каждый параметр имеет уникальный номер (item number). Всего определено более 150 параметров.

### 6.1 Идентификация устройства

| Параметр | Item # | Описание |
|----------|--------|----------|
| serialNumber | 062 | Серийный номер |
| serialNumberPart2 | 201 | Дополнительный серийный номер |
| firmwareVersion | 122 | Версия прошивки |
| firmwareChecksum | 986 | Контрольная сумма прошивки |
| productType | 874 | Тип продукта (E firmware) |

### 6.2 Дата и время

| Параметр | Item # | Формат |
|----------|--------|--------|
| date | 204 | dd MM yy |
| time | 203 | HH mm ss |
| gasDayStartTime | 205 | Начало газового дня |
| dateFormat | 262 | Формат даты |

### 6.3 Объемы газа

| Параметр | Item # | Описание |
|----------|--------|----------|
| corVol | 0 | Скорректированный объем |
| uncVol | 2 | Нескорректированный объем |
| corDailyVol | 223 | Дневной скорректированный объем |
| uncDailyVol | 224 | Дневной нескорректированный объем |
| corPrevDayVol | 183 | Скорр. объем за предыдущий день |
| uncPrevDayVol | 184 | Нескорр. объем за предыдущий день |
| corHighResVol | 113 | Высокоточный скорр. объем |
| uncHighResVol | 767 | Высокоточный нескорр. объем |
| corFullVol | 808 | Полный скорр. объем |
| uncFullVol | 807 | Полный нескорр. объем |
| corLastSavedVol | 775 | Последний сохраненный скорр. |
| uncLastSavedVol | 774 | Последний сохраненный нескорр. |
| uncVolSinceMalf | 773 | Объем с момента неисправности |

### 6.4 Температура

| Параметр | Item # | Описание |
|----------|--------|----------|
| temp | 26 | Текущая температура |
| baseTemp | 34 | Базовая температура |
| tempFactor | 45 | Температурный фактор |
| tempHighLimit | 28 | Верхний лимит температуры |
| tempLowLimit | 27 | Нижний лимит температуры |
| maxTemp | 64 | Максимальная температура |
| minTemp | 65 | Минимальная температура |
| maxTempDate | 295 | Дата макс. температуры |
| maxTempTime | 294 | Время макс. температуры |
| minTempDate | 299 | Дата мин. температуры |
| minTempTime | 298 | Время мин. температуры |
| caseTemp | 31 | Температура корпуса |
| maxCaseTemp | 32 | Макс. температура корпуса |
| minCaseTemp | 33 | Мин. температура корпуса |

### 6.5 Давление

| Параметр | Item # | Описание |
|----------|--------|----------|
| absPress | 8 | Абсолютное давление |
| gaugePress | 811 | Манометрическое давление |
| basePress | 13 | Базовое давление |
| atmosphericPress | 14 | Атмосферное давление |
| pressFactor | 44 | Фактор давления |
| pressHighLimit | 10 | Верхний лимит давления |
| pressLowLimit | 11 | Нижний лимит давления |
| maxPress | 9 | Максимальное давление |
| minPress | 63 | Минимальное давление |
| maxPressDate | 287 | Дата макс. давления |
| maxPressTime | 286 | Время макс. давления |
| minPressDate | 291 | Дата мин. давления |
| minPressTime | 290 | Время мин. давления |
| lineGaugePress | 855 | Линейное манометрическое давление |
| diffPress | 858 | Дифференциальное давление |
| pressTransSn | 138 | Серийный номер датчика давления |
| pressTransRange | 137 | Диапазон датчика давления |

### 6.6 Сверхсжимаемость (Super X)

| Параметр | Item # | Описание |
|----------|--------|----------|
| fixedSuperXFactor | 47 | Фиксированный фактор Z |
| liveSuperXFactor | 116 | Динамический фактор Z |
| gasMoleCO2 | 55 | Мольная доля CO2 |
| gasMoleN2 | 54 | Мольная доля N2 |
| gasMoleH2 | 821 | Мольная доля H2 |
| gasMoleHs | 778 | Мольная доля H2S |
| gasSpecificGravity | 53 | Удельный вес газа |
| superXAlgo | 147 | Алгоритм (NX19/AGA8/SGERG88) |

### 6.7 Батарея

| Параметр | Item # | Описание |
|----------|--------|----------|
| batteryVoltage | 48 | Напряжение батареи |
| batteryLife | 769 | Срок службы |
| batteryRemaining | 59 | Остаток заряда (%) |
| batteryInstallDate | 772 | Дата установки |
| batteryType | 771 | Тип батареи |
| batteryMalfDate | 780 | Дата неисправности |
| batteryMalfTime | 779 | Время неисправности |

### 6.8 Расход (Flow Rate)

| Параметр | Item # | Описание |
|----------|--------|----------|
| corFlowRate | 828 | Скорректированный расход |
| uncFlowRate | 209 | Нескорректированный расход |
| uncFlowRateHighLimit | 164 | Верхний лимит расхода |
| uncFlowRateLowLimit | 809 | Нижний лимит расхода |
| uncPeakFlowRate | 198 | Пиковый расход |
| uncPeakFlowRateDate | 275 | Дата пикового расхода |
| uncPeakFlowRateTime | 274 | Время пикового расхода |
| peakFlowRateResetDate | 786 | Дата сброса пикового |
| peakFlowRateResetTime | 785 | Время сброса пикового |

### 6.9 Неисправности (Malfunction)

| Параметр | Item # | Описание |
|----------|--------|----------|
| isTempHigh | 146 | Флаг высокой температуры |
| isTempLow | 144 | Флаг низкой температуры |
| isPressHigh | 145 | Флаг высокого давления |
| isPressLow | 143 | Флаг низкого давления |
| isUncFlowRateHigh | 163 | Флаг высокого расхода |
| isUncFlowRateLow | 810 | Флаг низкого расхода |
| isAlarmOutput | 108 | Флаг тревоги |
| isPressTxdrMalf | 105 | Неисправность датчика давления |
| isTempTxdrMalf | 106 | Неисправность датчика температуры |
| isDpTxdrMalf | 861 | Неисправность датчика DP |
| isBatteryMalf | 99 | Неисправность батареи |
| isMemoryError | 824 | Ошибка памяти |

### 6.10 Дифференциальное давление (AdEM Tq)

| Параметр | Item # | Описание |
|----------|--------|----------|
| maxAllowableDp | 856 | Макс. допустимое DP |
| diffPress | 858 | Дифференциальное давление |
| qMonitorFunction | 860 | Функция Q-монитора |
| dpSensorSn | 854 | Серийный номер DP сенсора |
| dpSensorRange | 853 | Диапазон DP сенсора |
| dpTestPressure | 869 | Тестовое давление DP |
| qCoefficientA | 864 | Коэффициент A |
| qCoefficientC | 865 | Коэффициент C |
| diffUncertainty | 867 | Погрешность |
| qSafetyMultiplier | 868 | Множитель безопасности |

### 6.11 Калибровка

| Параметр | Item # | Описание |
|----------|--------|----------|
| dpADReadingCts | 794 | АЦП дифф. давления |
| pressADReadCounts | 793 | АЦП давления |
| tempADReadCounts | 794 | АЦП температуры |
| dpCalib1PtOffset | 845 | 1-точечная калибр. DP |
| pressCalib1PtOffset | 845 | 1-точечная калибр. давления |
| tempCalib1PtOffset | 792 | 1-точечная калибр. температуры |
| onePtTempTarget | 823 | Целевая температура 1-точ. |
| threePtDpCalibParams | 790 | 3-точечная калибр. DP |
| threePtPressCalibParams | 790 | 3-точечная калибр. давления |
| threePtTempCalibParams | 791 | 3-точечная калибр. температуры |

### 6.12 Конфигурация единиц измерения

| Параметр | Item # | Описание |
|----------|--------|----------|
| pressUnit | 87 | Единицы давления |
| tempUnit | 89 | Единицы температуры |
| uncVolUnit | 92 | Единицы нескорр. объема |
| corVolUnit | 90 | Единицы скорр. объема |
| uncVolDigits | 97 | Разрядность нескорр. объема |
| corVolDigits | 96 | Разрядность скорр. объема |
| inputPulseVolUnit | 98 | Единицы входного импульса |
| uncOutputPulseVolUnit | 816 | Единицы выходного нескорр. |
| corOutputPulseVolUnit | 817 | Единицы выходного скорр. |
| differentialPressureUnit | 980 | Единицы DP |
| lineGaugePressureUnit | 981 | Единицы линейного давления |

### 6.13 Пользовательский дисплей

| Параметр | Item # | Описание |
|----------|--------|----------|
| cstmDispParam1-15 | 75-86, 787-789 | Параметры 1-15 |
| intervalField5-10 | 229-234 | Поля интервального лога |
| outputPulseChannel1-3 | 93-95 | Каналы выходных импульсов |
| displayTestPattern | 61 | Тестовый паттерн |

---

## 7. Процесс подключения к устройству

### 7.1 Последовательность команд

```dart
// 1. Сканирование устройств
BluetoothConnectionManager().startDeviceScan();

// 2. Подключение к донглу
await BluetoothConnectionManager().connect(device);

// 3. Пробуждение AdEM
await AdemManager().wakeUp();  // Отправляет ENQ, ждет ACK

// 4. Установка соединения с кодом доступа
await AdemManager().connect('21213');  // Код по умолчанию: 21213

// 5. Чтение параметров
await AdemManager().read(122);  // Чтение версии прошивки

// 6. Отключение
await AdemManager().disconnect();
```

### 7.2 Структура команды подключения

```
SN,21213<STX>vqAA<ETX>[CRC]<EOT>
```

### 7.3 Команды протокола

| Протокол | Код | Описание |
|----------|-----|----------|
| read | RD | Чтение параметра |
| write | WD | Запись параметра |
| readLocation | RS | Чтение локации |
| writeLocation | WS | Запись локации |
| readCustomerId | RI | Чтение ID клиента |
| writeCustomerId | WI | Запись ID клиента |
| dailyLog | RM | Дневной лог |
| eventLog | RE | Лог событий |
| eventLogAdem25 | EE | Лог событий (AdEM 25) |
| intervalLog | DD | Интервальный лог |
| readAlarmLogger | RL | Лог тревог |
| readAlarmLoggerAdem25 | LL | Лог тревог (AdEM 25) |
| qLog | RQ | Q-margin лог |
| flowDpLog | RF | Лог потока/DP |
| changeAccessCode | CA | Смена кода доступа |
| changeSuperAccess | CC | Смена суперкода |
| disconnectLink | SF | Отключение |
| readEEPROM | ER | Чтение EEPROM напрямую |
| writeEEPROM | EW | Запись EEPROM напрямую |
| provingMode | PR | Режим проверки |
| firmwareUpdate | WM | Обновление прошивки |
| cleanMemory | CM | Очистка памяти |

### 7.4 Предопределенные сообщения (PMessage)

| Сообщение | Код | Описание |
|-----------|-----|----------|
| acknowledge | 00 | Подтверждение |
| formatError | 01 | Ошибка формата |
| signOn | 20 | Вход |
| timeOutError | 21 | Таймаут |
| frameError | 22 | Ошибка кадра |
| crcError | 23 | Ошибка CRC |
| incorrectInstrumentAccessCode | 27 | Неверный код доступа |
| incorrectCommandCode | 28 | Неверный код команды |
| incorrectItemNumber | 29 | Неверный номер параметра |
| invalidEnquiry | 30 | Недопустимый запрос |
| tooManyAuditTrailRequests | 31 | Слишком много запросов |
| readOnlyMode | 32 | Режим только чтения |
| noIntervalLog | 33 | Нет интервального лога |
| eventLogLocked | 34 | Лог событий заблокирован |
| noEventLog | 36 | Нет лога событий |
| noAlarmOrDailyLog | 37 | Нет лога тревог/дневного |
| noQRLog | 38 | Нет Q-margin лога |
| noDpLog | 39 | Нет DP лога |
| agaConfigRefuse | 41 | AGA конфиг отклонен |

---

## 8. Кэширование данных

Пакет использует `CacheManager` (singleton) для хранения данных устройства.

### 8.1 ConfigCache

```dart
class ConfigCache extends Equatable {
  final DateTime gasDayStartTime;    // Начало газового дня
  final UnitDateFmt dateFmt;         // Формат даты
  final String timeFmt;              // Формат времени
  final DateTime? lastSaveDate;      // Дата последнего сохранения
  final DateTime? lastSaveTime;      // Время последнего сохранения
  final int backupIdxCounter;        // Счетчик резервных копий
  final String dispTestPattern;      // Тестовый паттерн дисплея
  final BatteryType batteryType;     // Тип батареи
  final bool isSealed;               // Запечатан ли прибор
}
```

### 8.2 MeasureCache

```dart
class MeasureCache extends Equatable {
  final MeterSize? meterSize;              // Размер счетчика
  final bool? isDotShowed;                 // Показывать точку
  final VolumeUnit? uncVolUnit;            // Единицы нескорр. объема
  final VolumeUnit? corVolUnit;            // Единицы скорр. объема
  final VolDigits? uncVolDigits;           // Разрядность нескорр.
  final VolDigits? corVolDigits;           // Разрядность скорр.
  final DispVolSelect? dispVolSelect;      // Выбор отображения объема
  final FactorType? superXFactorType;      // Тип фактора Z
  final SuperXAlgo? superXAlgorithm;       // Алгоритм Z
  final IntervalLogType intervalType;      // Тип интервального лога
  final IntervalLogInterval? intervalSetting; // Интервал
  final List<IntervalLogField?>? intervalFields; // Поля интервала
  final FactorType? pressFactorType;       // Тип фактора давления
  final PressUnit? pressUnit;              // Единицы давления
  final PressTransType? pressTransType;    // Тип датчика давления
  final DiffPressUnit? differentialPressureUnit; // Единицы DP
  final LineGaugePressUnit? lineGaugePressureUnit; // Единицы лин. давления
  final FactorType? tempFactorType;        // Тип фактора температуры
  final TempUnit? tempUnit;                // Единицы температуры
  final InputPulseVolumeUnit? inputPulseVolUnit; // Единицы вх. импульса
  final VolumeUnit? uncOutputPulseVolUnit; // Единицы вых. нескорр.
  final VolumeUnit? corOutputPulseVolUnit; // Единицы вых. скорр.
}
```

### 8.3 CacheManager

```dart
class CacheManager {
  static final _manager = CacheManager._internal();
  factory CacheManager() => _manager;
  
  ConfigCache getConfig();
  MeasureCache getMeasure();
  PushButtonModule getPushButtonModule();
  
  void cacheConfig(ConfigCache data);
  void cacheMeasure(MeasureCache data);
  void cachePushButtonModule(PushButtonModule data);
  void clear();
}
```

---

## 9. Типы логов

| Тип лога | Протокол | Описание |
|----------|----------|----------|
| Daily | RM | Суточные данные |
| Interval | DD | Интервальные данные (5-60 мин) |
| Event | RE/EE | События (изменения настроек) |
| Alarm | RL/LL | Тревоги и неисправности |
| Q | RQ | Q-margin (только AdEM Tq) |
| FlowDp | RF | Поток/DP (только AdEM Tq) |

### 9.1 Параметры интервального лога

```dart
enum IntervalLogType {
  fullFields(0),        // Полные поля
  selectableFields(1),  // Выбираемые поля
  fixed4Fields(2);      // Фиксированные 4 поля
}

enum IntervalLogInterval {
  minutes5(5),
  minutes15(15),
  minutes30(30),
  minutes60(60),
  hours2(2),
  hours6(6),
  hours12(12),
  hours24(24);
}
```

---

## 10. Единицы измерения

### 10.1 Объем

#### Imperial (кубические футы)

| Единица | Ключ | Описание |
|---------|------|----------|
| cf1 | 3 | 1 куб. фут |
| cf10 | 4 | 10 куб. футов |
| cf100 | 5 | 100 куб. футов |
| cf1000 | 6 | 1000 куб. футов |
| cf10000 | 14 | 10000 куб. футов |

#### Metric (кубические метры)

| Единица | Ключ | Описание |
|---------|------|----------|
| m301 | 9 | 0.1 куб. метра |
| m31 | 10 | 1 куб. метр |
| m310 | 11 | 10 куб. метров |
| m3100 | 12 | 100 куб. метров |

### 10.2 Давление

| Единица | Ключ | Десятичные знаки |
|---------|------|------------------|
| PSI | 1 | 2 |
| kPa | 2 | 1 |
| Bar | 4 | 3 |

### 10.3 Температура

| Единица | Ключ | Десятичные знаки |
|---------|------|------------------|
| Fahrenheit | 0 | 1 |
| Celsius | 1 | 1 |

### 10.4 Коэффициенты конвертации

```dart
const kpaToPsiOffset = 0.145038;
const kpaToBarOffset = 0.01;
const kpaToInH2oOffset = 4.018598072;
const cToFScale = 1.8;
const cToFOffset = 32.0;
```

---

## 11. Защищенные параметры

Параметры, защищенные при запечатанном приборе (`sealProtectedParams`):

```dart
const Set<int> sealProtectedParams = {
  0,    // corVol
  2,    // uncVol
  13,   // basePress
  34,   // baseTemp
  87,   // pressUnit
  90,   // corVolUnit
  92,   // uncVolUnit
  109,  // pressFactorType
  110,  // superXFactorType
  111,  // tempFactorType
  112,  // pressTransType
  122,  // firmwareVersion
  123,  // isEventLogEnable
  138,  // pressTransSn
  147,  // superXAlgo
  62,   // serialNumber
  768,  // meterSize
  790-805, // калибровочные параметры
  823,  // onePtTempTarget
  841,
  845,
  994,
};
```

---

## 12. Недоступные параметры по типам устройств

### 12.1 AdEM S (33 параметра)

```dart
const Set<int> unavailableParamsAdemS = {
  8, 9, 10, 11, 13, 14, 26, 27, 28, 53, 54, 55, 63, 64, 65, 87, 98, 
  110, 111, 112, 116, 47, 137, 138, 147, 301-312, 778, 811, 821, 860, 988
};
```

### 12.2 AdEM T (~30 параметров)

```dart
const Set<int> unavailableParamsAdemT = {
  8, 9, 10, 11, 13, 14, 54, 55, 63, 87, 98, 110, 111, 112, 116, 47,
  137, 138, 147, 301-312, 778, 811, 821, 860
};
```

### 12.3 AdEM Tq (~35 параметров)

```dart
const Set<int> unavailableParamsAdemTq = {
  8, 9, 10, 11, 13, 54, 55, 63, 87, 88, 98, 110, 112, 116, 47, 137,
  138, 140, 142, 147, 285-291, 778, 781, 782, 811, 821, 833, 835, 837-839
};
```

### 12.4 Universal T (~74 параметра)

```dart
const Set<int> unavailableParamsUniversalT = {
  8, 9, 10, 11, 13, 14, 53, 54, 55, 63, 87, 98, 110, 111, 112, 116,
  47, 137, 138, 140, 142, 285-291, 778, 781, 782, 811, 821, 833, 835,
  837-839, 860-872, 877, 980, 981, 989-992, 996
};
```

---

## 13. Таймауты коммуникации

| Операция | Таймаут (мс) | Описание |
|----------|--------------|----------|
| sendCommandTimeoutInMs | 5 | Отправка команды |
| wakeUpTimeoutInMs | 3000 | Пробуждение |
| connectTimeoutInMs | 3000 | Подключение |
| disconnectTimeoutInMs | 1500 | Отключение |
| disconnectLogTimeoutInMs | 10000 | Отключение с логами |
| readParamTimeoutInMs | 10000 | Чтение параметра |
| writeParamTimeoutInMs | 3000 | Запись параметра |
| readLogTimeoutInMs | 15000 | Чтение логов |
| readDongleTimeoutInMs | 3000 | Чтение от донгла |
| readBattTimeoutInMs | 10000 | Чтение батареи |
| retryMs | 30000 | Таймаут повторной попытки |
| retryDelay | 500 | Задержка между попытками |
| ademConnTimeoutInSec | 7200 | Общий таймаут (2 часа) |

---

## 14. Обработка ошибок

### 14.1 AdemCommErrorType

| Ошибка | Описание |
|--------|----------|
| communicationTimeout | Таймаут 1 час |
| unsupportedAdemType | Неподдерживаемый тип AdEM |
| unsupportedFirmware | Неподдерживаемая прошивка |
| checkProductType | Проверьте тип продукта (E) |
| firmwareNotFound | Прошивка не найдена |
| productTypeNotFound | Тип продукта не найден |
| serialNumberNotFound | Серийный номер не найден |
| receiveCrcError | Неверный CRC ответа |
| receiveTimeout | Нет данных/ошибка данных |
| ademSwitched | Подключено другое устройство |
| formatError (PM01) | Ошибка формата |
| timeOutError (PM21) | Таймаут |
| frameError (PM22) | Ошибка кадра |
| crcError (PM23) | CRC ошибка от устройства |
| incorrectInstrumentAccessCode (PM27) | Неверный код доступа |
| incorrectCommandCode (PM28) | Неверный код команды |
| incorrectItemNumber (PM29) | Неверный номер параметра |
| invalidEnquiry (PM30) | Недопустимый запрос |
| tooManyAuditTrailRequests (PM31) | Слишком много запросов |
| readOnlyMode (PM32) | Режим только чтения |
| eventLogLocked (PM34) | Лог событий заблокирован |
| dongleBatteryFail | Ошибка чтения батареи донгла |
| connectionBroken | Проверьте соединение |
| trashBytes | Обнаружены мусорные байты |
| calibrationNullParam | Ошибка калибровки |
| paramUpdateNotAllowed | Обновление запрещено |

### 14.2 Класс ошибки

```dart
class AdemCommError implements Exception {
  final AdemCommErrorType type;
  final String? message;
  
  const AdemCommError(this.type, [this.message]);
}
```

---

## 15. Размеры счетчиков (MeterSize)

### 15.1 Romet Imperial

| Размер | Ключ | Макс. расход |
|--------|------|--------------|
| RM600 | 0 | 600 CFH |
| RM1000 | 1 | 1000 CFH |
| RM1500 | 2 | 1500 CFH |
| RM2000 | 3 | 2000 CFH |
| RM3000 | 4 | 3000 CFH |
| RM5000 | 5 | 5000 CFH |
| RM7000 | 6 | 7000 CFH |
| RM11000 | 7 | 11000 CFH |
| RM16000 | 8 | 16000 CFH |
| RM23000 | 9 | 23000 CFH |
| RM25000 | 10 | 25000 CFH |
| RM38000 | 11 | 38000 CFH |
| RM56000 | 12 | 56000 CFH |

### 15.2 Romet Hard Metric

| Размер | Ключ | Макс. расход (m³/h) |
|--------|------|---------------------|
| G10 | 19 | 16 |
| G16 | 20 | 25 |
| G25 | 21 | 40 |
| G40 | 22 | 65 |
| G65 | 23 | 100 |
| G100 | 24 | 160 |
| G160 | 25 | 250 |
| G250 | 26 | 400 |
| G400 | 27 | 650 |
| G650 | 29 | 1100 |
| G1000 | 30 | 1600 |

### 15.3 Dresser LMMA Imperial

| Размер | Ключ | Макс. расход (CFH) |
|--------|------|-------------------|
| 1.5MLMMA | 13 | 1500 |
| 3MLMMA | 14 | 3000 |
| 5MLMMA | 15 | 5000 |
| 7MLMMA | 16 | 7000 |
| 11MLMMA | 17 | 11000 |
| 16MLMMA | 18 | 16000 |
| 23MLMMA | 90 | 23000 |
| 38MLMMA | 91 | 38000 |
| 56MLMMA | 92 | 56000 |
| 102MLMMA | 93 | 102000 |

---

## 16. Алгоритмы сверхсжимаемости

```dart
enum SuperXAlgo {
  nx19(0),    // NX-19
  aga8(1),    // AGA8 Detail
  sgerg88(2), // SGerg 88
  aga8G1(3),  // AGA8 Gross 1
  aga8G2(4);  // AGA8 Gross 2
}
```

### 16.1 Параметры AGA8

```dart
enum Aga8Param {
  methane,          // CH4
  nitrogen,         // N2
  carbonDioxide,    // CO2
  ethane,           // C2H6
  propane,          // C3H8
  water,            // H2O
  hydrogenSulphide, // H2S
  hydrogen,         // H2
  carbonMonoxide,   // CO
  oxygen,           // O2
  isoButane,        // i-C4H10
  nButane,          // n-C4H10
  isoPentane,       // i-C5H12
  nPentane,         // n-C5H12
  nHexane,          // n-C6H14
  nHeptane,         // n-C7H16
  nOctane,          // n-C8H18
  nNonane,          // n-C9H20
  nDecane,          // n-C10H22
  helium,           // He
  argon,            // Ar
}
```

---

## 17. Тесты

### 17.1 Доступные тесты

```
test/
├── aga8_calculation_test.dart      # Расчеты AGA8
├── crc_calculation_test.dart       # Проверка CRC-16-CCITT
├── firmware_version_test.dart      # Парсинг версии прошивки
├── serial_number_part_2_test.dart  # Проверка серийных номеров
└── super_access_code_test.dart     # Проверка суперкодов доступа
```

### 17.2 Запуск тестов

```bash
cd packages/ademlync_device
flutter test

# Запуск конкретного теста
flutter test test/crc_calculation_test.dart
```

---

## 18. Резюме

Пакет `ademlync_device` — это профессиональная библиотека для работы с газовыми счетчиками AdEM через BLE-донглы.

### 18.1 Ключевые возможности

1. **BLE-коммуникация** через AdEM Key или Air Console
2. **Чтение/запись 150+ параметров** EEPROM устройства
3. **Загрузка логов** (дневные, интервальные, события, тревоги, Q-margin, DP)
4. **Калибровка** датчиков давления и температуры (1-точечная и 3-точечная)
5. **Поддержка 8 типов** устройств AdEM
6. **Валидация CRC-16-CCITT** всех сообщений
7. **Кэширование** конфигурации и измерений
8. **Обработка 20+ типов ошибок** коммуникации

### 18.2 Архитектурные паттерны

- **Singleton** для BluetoothConnectionManager, AdemManager, CacheManager
- **Factory** для создания типов устройств по прошивке
- **Repository** для кэширования данных
- **Command** для построения BLE-команд

### 18.3 Требования

- Flutter SDK ≥ 1.17.0
- Dart SDK ≥ 3.10.0 < 4.0.0
- BLE-донгл (AdEM Key или Air Console)
- Устройство AdEM с совместимой прошивкой

---

*Отчет создан автоматически на основе анализа исходного кода пакета.*
