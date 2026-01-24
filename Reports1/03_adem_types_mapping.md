# 03 - Маппинг типов AdEM и их особенности

## Enum AdemType

```dart
enum AdemType {
  ademS(3, 'RS', 1, 5),       // AdEM S
  ademT(3, 'RT', 1, 3),       // AdEM T
  universalT(3, 'MT', 1, 3),  // Universal T
  ademTq(3, '(M|R)Q', 1, 7),  // AdEM TQ
  ademPtz(2, '[NAGS](M|R)', 2, 4),   // AdEM PTZ
  ademPtzR(2, '[NAGS](M|R)', 2, 6),  // AdEM PTZ-R
  ademR(2, '[NAGS](M|R)', 2, 6),     // AdEM R
  ademMi(2, '[NAGS](M|R)', 2, 6);    // AdEM Mi
  
  // Параметры для построения regex
  final int prefixLength;     // Длина префикса (цифры после первой буквы)
  final String middlePattern; // Паттерн середины
  final int suffixLength;     // Длина суффикса
  final int lastDigit;        // Последняя цифра (идентификатор типа)
}
```

## Таблица соответствия Firmware -> Type

```
Firmware      Тип           Display Name
--------------------------------------------------
D050RS25      ademS         AdEM S
D050RT33      ademT         AdEM T
D050MT33      universalT    Universal T
D050MQ17      ademTq        AdEM Tq
D050RQ17      ademTq        AdEM Tq
D05NM014      ademPtz       AdEM PTZ
D05AM014      ademPtz       AdEM PTZ
D05GM014      ademPtz       AdEM PTZ
D05SM014      ademPtz       AdEM PTZ
D05NR014      ademPtz       AdEM PTZ (Romet)
D05NM016      ademPtzR      AdEM PTZ-r
D05NR016      ademPtzR      AdEM PTZ-r (Romet)
E010RQ17      ademTq        AdEM Tq (AdEM-25)
E01NR014      ademPtz       AdEM PTZ (AdEM-25)
```

## Недоступные параметры по типам

### AdEM S (unavailableParamsAdemS)
```
8, 9, 10, 11, 13, 14, 26, 27, 28, 53, 54, 55, 63, 64, 65, 
87, 98, 110, 111, 112, 116, 47, 137, 138, 147, 
301-312, 778, 811, 821, 860, 988
```

### AdEM T (unavailableParamsAdemT)
```
8, 9, 10, 11, 13, 14, 54, 55, 63, 87, 98, 110, 111, 112, 
116, 47, 137, 138, 147, 301-312, 778, 811, 821, 860
```

### AdEM TQ (unavailableParamsAdemTq)
```
8, 9, 10, 11, 13, 54, 55, 63, 87, 88, 98, 110, 112, 116, 
47, 137, 138, 140, 142, 147, 285-291, 778, 781, 782, 
811, 821, 833, 835, 837, 838, 839
```

### AdEM PTZ (unavailableParamsAdemPtz)
```
829, 833, 835, 837, 838, 839, 842, 843, 844, 853-859, 
860-872, 877, 980, 981, 988, 989, 990, 991, 992, 996
```

### Universal T (unavailableParamsUniversalT)
```
8, 9, 10, 11, 13, 14, 53, 54, 55, 63, 87, 98, 110, 111, 
112, 116, 47, 137, 138, 140, 142, 285-291, 778, 781, 
782, 811, 821, 833, 835, 837, 838, 839, 860-872, 
877, 980, 981, 989-992, 996
```

## Параметры Daily Log по типам

```
Тип           hasSuperX  hasTemp  hasDp  hasDpMeter  hasReynolds
-----------------------------------------------------------------
AdEM S        false      false    false  false       false
AdEM T        false      true     false  false       false
AdEM TQ       false      true     true   true        true
Universal T   false      true     false  false       false
AdEM PTZ      true       true     false  false       false
AdEM PTZ-R    true       true     false  false       false
```

## Параметры Interval Log по типам

```
Тип           hasSuperX  hasTemp  hasDp  hasDpMeter
----------------------------------------------------
AdEM S        false      false    false  false
AdEM T        false      true     false  false
AdEM TQ       false      true     true   true
AdEM PTZ      true       true     true   true
```

## Custom Display параметры

### AdEM S
```
0, 2, 43, 44, 48, 59, 61, 113, 115, 122, 183, 184, 198, 
62, 201, 203, 204, 209, 223, 224, 255, 274, 275, 767, 
768, 769, 772, 774, 775, 776, 777, 780, 806, 816, 817, 
828, 834, 840, 986 (если firmware >= D.6), 995
```

### AdEM T
Дополнительно к AdEM S:
```
26, 34, 45, 98, 773, 783, 784
```

### AdEM TQ
Дополнительно к AdEM T:
```
13, 14, 53, 795, 853-858, 860
```

### AdEM PTZ
Полный набор включая:
```
8, 54, 55, 116, 47, 137, 138, 781, 782, 811
```

## Поддержка функций по типам

### Super Access Code

```
Тип              Минимальная версия
-------------------------------------
AdEM S, AdEM T   D020 или выше
AdEM PTZ         D00X или выше
Остальные        Всегда поддерживается
```

### Serial Number Part 2

```
Тип              Минимальная версия
-------------------------------------
AdEM S           D050RS25 или выше
AdEM T           D050RT33 или выше
AdEM PTZ         D05XM014 или выше
Остальные        Всегда поддерживается
```

## Идентификаторы версий

### Major версии
- **D** - стандартные прошивки
- **E** - AdEM-25 (новое поколение)

### Значение последней цифры

```
Цифра    Тип
---------------------------------
5        AdEM S
3        AdEM T / Universal T
7        AdEM TQ
4        AdEM PTZ
6        AdEM PTZ-R / AdEM R / AdEM Mi
```

## NoDataSymbol по типам

```dart
String get noDataSymbol => switch (this) {
  AdemType.ademS || AdemType.ademT || AdemType.ademTq => 'NA',
  AdemType.universalT ||
  AdemType.ademPtz ||
  AdemType.ademPtzR ||
  AdemType.ademR ||
  AdemType.ademMi => '0',
};
```

Это значение возвращается устройством, когда параметр недоступен или не имеет данных.
