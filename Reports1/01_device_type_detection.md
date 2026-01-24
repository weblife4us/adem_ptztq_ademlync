# 01 - Механизм определения типа счетчика AdEM

## Общий принцип

Тип счетчика определяется на основе двух параметров:
1. **Firmware Version** (Item #122) - читается ВСЕГДА первым
2. **Product Type** (Item #874) - читается ТОЛЬКО если firmware начинается с "E" (AdEM-25)

## Последовательность определения типа

```
1. Wake Up устройства
   TX: [0x04] (EOT)
   TX: [0x05] (ENQ)
   RX: [0x06] (ACK)

2. Connect с кодом доступа
   TX: [SOH][SN,21213][STX][vqAA][ETX][CRC][EOT]
   RX: [SOH][00][ETX][CRC][EOT]  (00 = Acknowledge)

3. Чтение Firmware Version (Item #122)
   TX: [SOH][RD][STX][122][ETX][CRC][EOT]
   RX: [SOH][STX][D050RT33][ETX][CRC][EOT]

4. Если firmware начинается с "E":
   Чтение Product Type (Item #874)
   TX: [SOH][RD][STX][874][ETX][CRC][EOT]
   RX: [SOH][STX][ADEM-TQ][ETX][CRC][EOT]

5. Определение AdemType через factory метод
   AdemType.from(firmware, productType)
```

## Формат Firmware Version

### Структура строки firmware:

```
[Major][Minor][MiddlePattern][Suffix][LastDigit]

Примеры:
D050RS25 -> D | 050 | RS | 2 | 5
D050RT33 -> D | 050 | RT | 3 | 3
D050MQ17 -> D | 050 | MQ | 1 | 7
D05NM014 -> D | 05  | NM | 01| 4
E010RQ17 -> E | 010 | RQ | 1 | 7 (AdEM-25)
```

### Regex паттерны для каждого типа:

```
Тип          Regex                            Пример
---------------------------------------------------------------
AdEM S       ^\w\d{3}RS\d{1}5$                D050RS25
AdEM T       ^\w\d{3}RT\d{1}3$                D050RT33
Universal T  ^\w\d{3}MT\d{1}3$                D050MT33
AdEM TQ      ^\w\d{3}(M|R)Q\d{1}7$            D050MQ17, D050RQ17
AdEM PTZ     ^\w\d{2}[NAGS](M|R)\d{2}4$       D05NM014
AdEM PTZ-R   ^\w\d{2}[NAGS](M|R)\d{2}6$       D05NM016
AdEM R       ^\w\d{2}[NAGS](M|R)\d{2}6$       -
AdEM Mi      ^\w\d{2}[NAGS](M|R)\d{2}6$       -
```

### Параметры построения regex:

```
Тип          prefixLen  middle        suffixLen  lastDigit
---------------------------------------------------------------
AdEM S       3          RS            1          5
AdEM T       3          RT            1          3
Universal T  3          MT            1          3
AdEM TQ      3          (M|R)Q        1          7
AdEM PTZ     2          [NAGS](M|R)   2          4
AdEM PTZ-R   2          [NAGS](M|R)   2          6
AdEM R       2          [NAGS](M|R)   2          6
AdEM Mi      2          [NAGS](M|R)   2          6
```

### Расшифровка символов в middle pattern:

**Для PTZ моделей [NAGS]:**
- N = NX19
- A = AGA8 Detail
- G = AGA8 Gross 1 and Gross 2
- S = SGERG88

**Для протокола (M|R):**
- M = Modbus Protocols
- R = Romet Protocols (NO MODBUS) - используется в AdEM-25

## AdEM-25 (Firmware "E")

Для прошивок, начинающихся с "E", тип определяется через Product Type (#874):

```
Product Type         AdemType
---------------------------------
ADEM-T, ADEM+T       ademT
ADEM-TQ, ADEM+TQ     ademTq
ADEM-PTZ, ADEM+PTZ   ademPtz
ADEM-R, ADEM+R       ademR
ADEM-MI, ADEM+MI     ademMi
```

## Код определения типа (Dart)

```dart
factory AdemType.from(String firmware, String? productType) {
  // Для AdEM-25 (firmware начинается с "E")
  if (firmware.startsWith('E')) {
    final type = switch (productType?.trim().toUpperCase()) {
      'ADEM-T' || 'ADEM+T' => AdemType.ademT,
      'ADEM-TQ' || 'ADEM+TQ' => AdemType.ademTq,
      'ADEM-PTZ' || 'ADEM+PTZ' => AdemType.ademPtz,
      'ADEM-R' || 'ADEM+R' => AdemType.ademR,
      'ADEM-MI' || 'ADEM+MI' => AdemType.ademMi,
      null => throw AdemCommError(productTypeNotFound),
      _ => null,
    };
    if (type != null) return type;
  }

  // Для старых прошивок - определение по regex
  return AdemType.values.firstWhere(
    (e) => RegExp(e.regexPattern).hasMatch(firmware),
    orElse: () => throw AdemCommError(unsupportedFirmware),
  );
}
```

## Формат команды чтения параметра

```
Команда RD (Read):
[SOH][RD][STX][ItemNumber][ETX][CRC][EOT]

Где ItemNumber - 3-значный номер параметра с ведущими нулями
Firmware Version: 122
Product Type: 874

Пример чтения firmware:
TX: 01 52 44 02 31 32 32 03 [CRC] 04
    SOH R  D  STX 1  2  2  ETX CRC EOT
```

## Ответ устройства

```
[SOH][STX][DATA][ETX][CRC][EOT]

или для ошибки:
[SOH][PM][ETX][CRC][EOT]

PM (Pre-defined Message):
00 = Acknowledge
29 = Incorrect Item Number
```

## Item Numbers ключевых параметров

```
Параметр            Item #    Описание
----------------------------------------------------------
firmwareVersion     122       Версия прошивки (ключ типа)
productType         874       Тип продукта (для AdEM-25)
serialNumber        062       Серийный номер
serialNumberPart2   201       Вторая часть серийного номера
firmwareChecksum    986       Контрольная сумма прошивки
```

## Особенности по типам устройств

### NoDataSymbol

Разные типы устройств возвращают разный символ при отсутствии данных:

```
Типы                                         NoDataSymbol
----------------------------------------------------------
AdEM S, AdEM T, AdEM TQ                      "NA"
Universal T, AdEM PTZ, AdEM PTZ-R, R, Mi     "0"
```

### Поддержка Meter Size

Meter Size (#768) поддерживается только в:
- AdEM S
- AdEM T
- Universal T
- AdEM TQ
- AdEM PTZ

НЕ поддерживается в: AdEM PTZ-R, AdEM R, AdEM Mi
