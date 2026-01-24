# 02 - Детальный разбор байтов коммуникации

## Control Characters (Управляющие символы)

```
Символ    HEX     DEC    Описание
--------------------------------------------------
SOH       0x01    1      Start of Header
STX       0x02    2      Start of Text
ETX       0x03    3      End of Text
EOT       0x04    4      End of Transmission
ENQ       0x05    5      Enquiry (пробуждение)
ACK       0x06    6      Acknowledge
RS        0x1E    30     Record Separator
```

## Последовательность Wake Up

```
ПЕРЕДАЧА (TX):
[0x04]        EOT - сброс предыдущей сессии

ПЕРЕДАЧА (TX):
[0x05]        ENQ - запрос пробуждения

ОЖИДАНИЕ (RX):
[0x06]        ACK - устройство проснулось
```

## Команда Connection (Подключение)

```
ФОРМАТ:
[SOH][SN,ACCESS_CODE][STX][vqAA][ETX][CRC][EOT]

ПРИМЕР с кодом доступа 21213:
TX HEX: 01 53 4E 2C 32 31 32 31 33 02 76 71 41 41 03 [CRC] 04
TX DEC: SOH S  N  ,  2  1  2  1  3  STX v  q  A  A  ETX CRC EOT

ОТВЕТ (успех):
RX HEX: 01 30 30 03 [CRC] 04
RX DEC: SOH 0  0  ETX CRC EOT
        (00 = PMessage.acknowledge)
```

## Команда Read (Чтение параметра)

```
ФОРМАТ:
[SOH][RD][STX][ITEM_NUMBER][ETX][CRC][EOT]

ПРИМЕР чтения Firmware Version (Item #122):
TX HEX: 01 52 44 02 31 32 32 03 [CRC] 04
TX DEC: SOH R  D  STX 1  2  2  ETX CRC EOT

ОТВЕТ:
RX HEX: 01 02 44 30 35 30 52 54 33 33 03 [CRC] 04
RX DEC: SOH STX D  0  5  0  R  T  3  3  ETX CRC EOT
             (firmware = "D050RT33")
```

## Команда Read для Product Type (Item #874)

```
ПРИМЕР чтения Product Type:
TX HEX: 01 52 44 02 38 37 34 03 [CRC] 04
TX DEC: SOH R  D  STX 8  7  4  ETX CRC EOT

ОТВЕТ (для AdEM-25):
RX HEX: 01 02 41 44 45 4D 2D 54 51 03 [CRC] 04
RX DEC: SOH STX A  D  E  M  -  T  Q  ETX CRC EOT
             (productType = "ADEM-TQ")
```

## Структура ответа

```
ПОЛНЫЙ ФОРМАТ:
[SOH][HEAD][STX][BODY][ETX][CRC][EOT]

или для однобайтового ответа:
[ACK] или [ERROR_CODE]

Разбор в коде:
- rawHead: данные между SOH и STX
- rawBody: данные между STX и ETX
- rawCrc: данные между ETX и EOT
```

## CRC Calculation

CRC вычисляется для данных от SOH (или начала, если нет SOH) до ETX включительно.

```dart
String crcCalculation(List<int> bytes) {
  // Вычисление контрольной суммы
  // Результат - строка из 4 символов
}
```

## PMessage (Pre-defined Messages)

```
Код    Название                          Описание
----------------------------------------------------------
00     acknowledge                       Успешно
01     formatError                       Ошибка формата
21     timeOutError                      Таймаут
22     frameError                        Ошибка кадра
23     crcError                          Ошибка CRC
27     incorrectInstrumentAccessCode     Неверный код доступа
28     incorrectCommandCode              Неверная команда
29     incorrectItemNumber               Неверный номер параметра
```

## Пример полной сессии определения типа

```
=== 1. WAKE UP ===
TX: 04                          (EOT)
TX: 05                          (ENQ)
RX: 06                          (ACK) - устройство готово

=== 2. CONNECT ===
TX: 01 53 4E 2C 32 31 32 31 33 02 76 71 41 41 03 XX XX XX XX 04
    SOH "SN,21213" STX "vqAA" ETX [CRC 4 bytes] EOT
RX: 01 30 30 03 XX XX XX XX 04
    SOH "00" ETX [CRC] EOT - подключено

=== 3. READ FIRMWARE (Item #122) ===
TX: 01 52 44 02 31 32 32 03 XX XX XX XX 04
    SOH "RD" STX "122" ETX [CRC] EOT
RX: 01 02 44 30 35 30 52 54 33 33 03 XX XX XX XX 04
    SOH STX "D050RT33" ETX [CRC] EOT

=== 4. ОПРЕДЕЛЕНИЕ ТИПА ===
firmware = "D050RT33"
- Не начинается с "E" -> используем regex
- Паттерн для ademT: ^\w\d{3}RT\d{1}3$
- "D050RT33" соответствует паттерну
- Результат: AdemType.ademT

=== 5. DISCONNECT ===
TX: 01 53 46 03 XX XX XX XX 04
    SOH "SF" ETX [CRC] EOT
RX: 01 30 30 03 XX XX XX XX 04
    SOH "00" ETX [CRC] EOT - отключено
```

## Пример для AdEM-25 (firmware "E")

```
=== 3. READ FIRMWARE (Item #122) ===
TX: 01 52 44 02 31 32 32 03 XX XX XX XX 04
RX: 01 02 45 30 31 30 52 51 31 37 03 XX XX XX XX 04
         "E010RQ17"
firmware = "E010RQ17" - начинается с "E"!

=== 4. READ PRODUCT TYPE (Item #874) ===
TX: 01 52 44 02 38 37 34 03 XX XX XX XX 04
RX: 01 02 41 44 45 4D 2D 54 51 03 XX XX XX XX 04
         "ADEM-TQ"

=== 5. ОПРЕДЕЛЕНИЕ ТИПА ===
firmware = "E010RQ17" (начинается с "E")
productType = "ADEM-TQ"
- switch по productType.toUpperCase()
- "ADEM-TQ" -> AdemType.ademTq
- Результат: AdemType.ademTq
```

## Таблица ASCII кодов для команд

```
Символ    HEX     DEC
-----------------------
R         0x52    82
D         0x44    68
S         0x53    83
N         0x4E    78
F         0x46    70
,         0x2C    44
0         0x30    48
1         0x31    49
2         0x32    50
-         0x2D    45
```
