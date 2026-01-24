# 02 - Протокол коммуникации

## Bluetooth Low Energy (BLE)

### Service UUID

| Устройство | Service UUID |
|------------|--------------|
| AdEM Key (Dragonfly) | `6e400001-b5a3-f393-e0a9-e50e24dcca9e` |
| Air Console | `0f1e4b13-16d2-4396-bf25-000000000000` |

### Characteristic UUID

| Устройство | Read | Write |
|------------|------|-------|
| AdEM Key | `6e400003-b5a3-f393-e0a9-e50e24dcca9e` | `6e400002-b5a3-f393-e0a9-e50e24dcca9e` |
| Air Console | `0f1e4b13-16d2-4396-bf25-000000000001` | `0f1e4b13-16d2-4396-bf25-000000000001` |

## Структура команды

```
[SOH] [COMMAND_BYTES] [CRC] [EOT]
```

### Control Characters

| Символ | Код | Описание |
|--------|-----|----------|
| SOH | 0x01 | Start of Header |
| STX | 0x02 | Start of Text |
| ETX | 0x03 | End of Text |
| EOT | 0x04 | End of Transmission |
| ENQ | 0x05 | Enquiry (Wake Up) |
| ACK | 0x06 | Acknowledge |
| RS | 0x1E | Record Separator |

## Протоколы команд

| Команда | Код | Описание |
|---------|-----|----------|
| RD | Read | Чтение параметра |
| WD | Write | Запись параметра |
| RS | ReadLocation | Чтение локации |
| RI | ReadCustomerId | Чтение ID клиента |
| WS | WriteLocation | Запись локации |
| WI | WriteCustomerId | Запись ID клиента |
| RM | DailyLog | Ежедневный лог |
| RE | EventLog | Лог событий |
| DD | IntervalLog | Интервальный лог |
| RL | ReadAlarmLogger | Лог аварий |
| RQ | QLog | Q-лог |
| RF | FlowDpLog | Лог перепада давления |
| CA | ChangeAccessCode | Смена кода доступа |
| CC | ChangeSuperAccess | Смена супер-кода |
| SF | DisconnectLink | Разрыв соединения |

## Последовательность подключения

1. **Wake Up** - отправка EOT, затем ENQ
2. **Connect** - команда SN с кодом доступа (по умолчанию: `21213`)
3. **Read/Write** - операции с параметрами
4. **Disconnect** - команда SF

## Таймауты

| Операция | Таймаут (мс) |
|----------|--------------|
| Wake Up | 3000 |
| Connect | 3000 |
| Disconnect | 1500 |
| Read Parameter | 10000 |
| Write Parameter | 3000 |
| Read Log | 15000 |
| Read Dongle | 3000 |

## Предопределенные сообщения (PMessage)

| Код | Описание |
|-----|----------|
| 00 | Acknowledge |
| 01 | Format Error |
| 21 | Timeout Error |
| 22 | Frame Error |
| 23 | CRC Error |
| 27 | Incorrect Access Code |
| 28 | Incorrect Command Code |
| 29 | Incorrect Item Number |
| 33 | No Interval Log |
| 36 | No Event Log |
| 37 | No Alarm/Daily Log |

## CRC расчет

Используется CRC для валидации данных. Расчет выполняется в функции `crcCalculation()`.
