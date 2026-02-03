import 'dart:developer';

import 'functions.dart';
import 'package:intl/intl.dart';

import '../models/adem/adem.dart';
import '../models/aga8_config.dart';
import '../models/log/log.dart';
import 'adem_param.dart';
import 'data_parser.dart';

class LogParser {
  /// Daily log data convert parser
  static DailyLog? daily(String rawData, int logId, AdemType type) {
    final isAdemTq = type == AdemType.ademTq;
    final dataList = rawData.split(',');
    try {
      return DailyLog(
        logId,
        DataParser.asDate(_dateTimeFmt(dataList[0])),
        DataParser.asTime(_dateTimeFmt(dataList[1])),
        DataParser.asInt(dataList[2]) ?? 0,
        DataParser.asInt(dataList[3]) ?? 0,
        DataParser.asDouble(dataList[4]),
        DataParser.asDouble(dataList[5]),
        DataParser.asDouble(dataList[6])!,
        DataParser.asNum(dataList[7])!,
        DataParser.asNum(dataList[8])!,
        DataParser.asDouble(dataList[9])!,
        isAdemTq ? DataParser.asNum(dataList[10]) : null,
        isAdemTq ? DataParser.asDouble(dataList[11]) : null,
        isAdemTq
            ? DataParser.asDouble(dataList[12])?.toString() ??
                  dataList[12].trim()
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Event log data convert parser
  static List<EventLog> event(String rawData, Adem adem, bool is24HFmt) {
    final dataList = rawData.split(',');
    try {
      final param = Param.from(int.parse(dataList[4]));
      switch (param) {
        case Param.threePtDpCalibParams:
        case Param.threePtPressCalibParams:
        case Param.threePtTempCalibParams:
          return _event3PtCalibra(dataList, param, adem);
        case Param.aga8GasComponentMolar:
          return _eventAga8(dataList, param);
        case Param.unknown:
          return [_eventNoParam(dataList)];
        default:
          return [_eventParam(dataList, param, adem, is24HFmt)];
      }
    } catch (e) {
      return [];
    }
  }

  /// Alarm log data convert parser
  static AlarmLog? alarm(String rawData, int logId) {
    final dataList = rawData.split(',');
    try {
      return AlarmLog(
        logId,
        DataParser.asDate(_dateTimeFmt(dataList[1])),
        DataParser.asTime(_dateTimeFmt(dataList[2])),
        DataParser.asInt(dataList[3])!,
        dataList[4].trim(),
        dataList[5].trim(),
        _DataParser.alarmLogType(dataList[0])!,
      );
    } catch (e) {
      return null;
    }
  }

  /// Q log data convert parser
  static QLog? q(String rawData, int logId) {
    final dataList = rawData.split(',');
    try {
      return QLog(
        logId,
        DataParser.asQLogDate(_dateTimeFmt(dataList[0]))!,
        null,
        DataParser.asNum(dataList[1]),
        DataParser.asDouble(dataList[2]),
        DataParser.asNum(dataList[3]),
        DataParser.asNum(dataList[4]),
      );
    } catch (e) {
      return null;
    }
  }

  /// Flow DP log data convert parser
  static FlowDpLog? flowDp(String rawData, int logId) {
    final dataList = rawData.split(',');
    try {
      return FlowDpLog(
        logId,
        DataParser.asDate(_dateTimeFmt(dataList[0])),
        DataParser.asTime(_dateTimeFmt(dataList[1])),
        DataParser.asDouble(dataList[2]),
        DataParser.asDouble(dataList[3])?.toString() ?? dataList[3].trim(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Interval log data convert parser
  static IntervalLog? interval(
    String rawData,
    int logId,
    IntervalLogType intervalType,
    AdemType ademType,
    List<IntervalLogField>? intervalFields,
    VolumeType volumeType,
  ) {
    final dataList = rawData.split(',');

    return switch (intervalType) {
      IntervalLogType.fullFields => _intervalFullFields(
        dataList,
        logId,
        ademType,
        volumeType,
      ),
      IntervalLogType.selectableFields => _intervalSelectableFields(
        dataList,
        logId,
        ademType,
        intervalFields!,
        volumeType,
      ),
      IntervalLogType.fixed4Fields => _intervalFixed4Fields(
        dataList,
        logId,
        ademType,
        volumeType,
      ),
    };
  }

  /// Event Log -- Create no param log record
  static EventLog _eventNoParam(List<String> list) {
    return EventLog(
      DataParser.asInt(list[0])!,
      DataParser.asDate(_dateTimeFmt(list[2])),
      DataParser.asTime(_dateTimeFmt(list[3])),
      DataParser.asInt(list[1])!,
      null,
      null,
      list[5],
      list[6],
      '-',
      _DataParser.eventLogAction(list[list.length - 1])!,
    );
  }

  /// Event Log -- Handle the 3 point calibration
  static List<EventLog> _event3PtCalibra(
    List<String> list,
    Param param,
    Adem adem,
  ) {
    return [
      _DataParser.eventLogHeader(list, param.key),
      for (var i = 0; i < 3; i++)
        EventLog(
          0,
          DateTime.now(),
          DateTime.now(),
          0,
          0,
          {0: 'Low Point', 1: 'Middle Point', 2: 'High Point'}[i],
          _DataParser.eventLog3PtCalibra(list[5], param, adem)![i],
          _DataParser.eventLog3PtCalibra(list[6], param, adem)![i],
          switch (param) {
            Param.threePtDpCalibParams =>
              adem.differentialPressureUnit!.displayName,
            Param.threePtPressCalibParams => adem.pressUnit!.displayName,
            _ => adem.tempUnit!.displayName,
          },
          EventLogActionType.shutDown,
        ),
    ];
  }

  /// Event Log -- Handle the Aga8
  static List<EventLog> _eventAga8(List<String> list, Param param) {
    final oldData = Aga8Config.from(list[5]);
    final newData = Aga8Config.from(list[6]);
    return [
      _DataParser.eventLogHeader(list, param.key),
      if (oldData != null && newData != null)
        for (var e in Aga8Param.values)
          EventLog(
            0,
            DateTime.now(),
            DateTime.now(),
            0,
            0,
            e.formula,
            _DataParser.eventLogAga8(oldData, e).toStringAsFixed(2),
            _DataParser.eventLogAga8(newData, e).toStringAsFixed(2),
            '%',
            EventLogActionType.shutDown,
          ),
    ];
  }

  /// Event Log -- Create log record
  static EventLog _eventParam(
    List<String> list,
    Param param,
    Adem adem,
    bool is24HFmt,
  ) {
    return EventLog(
      DataParser.asInt(list[0])!,
      DataParser.asDate(_dateTimeFmt(list[2])),
      DataParser.asTime(_dateTimeFmt(list[3])),
      DataParser.asInt(list[1])!,
      param.key,
      null,
      _DataParser.eventLogParam(list[5], param, adem, is24HFmt),
      _DataParser.eventLogParam(list[6], param, adem, is24HFmt),
      switch (param) {
        Param.date => 'MMM dd, yyyy',
        Param.time || Param.gasDayStartTime => is24HFmt ? 'HH:mm' : 'hh:mm a',
        _ => param.unit(adem) ?? '-',
      },
      _DataParser.eventLogAction(list[list.length - 1])!,
    );
  }

  /// Interval Log -- Handle the full field interval log
  static IntervalLog? _intervalFullFields(
    List<String> list,
    int logId,
    AdemType ademType,
    VolumeType volumeType,
  ) {
    final isSOrT = ademType == AdemType.ademS || ademType == AdemType.ademT;
    try {
      return IntervalLog(
        logId++,
        DataParser.asDate(_dateTimeFmt(list[0])),
        DataParser.asTime(_dateTimeFmt(list[1])),
        corIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[2])) ?? 0,
        uncIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[3])) ?? 0,
        avgPress: DataParser.asDouble(list[4]),
        avgTemp: DataParser.asDouble(list[5]),
        corTotalVol: !isSOrT
            ? volumeType.volumeMultiplier(DataParser.asNum(list[6]))
            : null,
        uncTotalVol: volumeType.volumeMultiplier(DataParser.asNum(list[7])),
        avgTotalFactor: DataParser.asDouble(list[8]),
        uncAvgFlowRate: DataParser.asNum(list[isSOrT ? 6 : 9]),
        uncMaxFlowRate: !isSOrT ? DataParser.asNum(list[10]) : null,
        uncMaxFlowRateTime: !isSOrT ? _DataParser.intervalTime(list[11]) : null,
        maxPress: !isSOrT ? DataParser.asDouble(list[12]) : null,
        maxPressTime: !isSOrT ? _DataParser.intervalTime(list[13]) : null,
        minPress: !isSOrT ? DataParser.asDouble(list[14]) : null,
        minPressTime: !isSOrT ? _DataParser.intervalTime(list[15]) : null,
        maxTemp: !isSOrT ? DataParser.asDouble(list[16]) : null,
        maxTempTime: !isSOrT ? _DataParser.intervalTime(list[17]) : null,
        minTemp: !isSOrT ? DataParser.asDouble(list[18]) : null,
        minTempTime: !isSOrT ? _DataParser.intervalTime(list[19]) : null,
        uncMinFlowRate: !isSOrT ? DataParser.asNum(list[20]) : null,
        uncMinFlowRateTime: !isSOrT ? _DataParser.intervalTime(list[21]) : null,
        avgBatteryVoltage: DataParser.asDouble(list[isSOrT ? 7 : 22]),
        alarms: _intervalLogAlarm(list.last, ademType)!,
      );
    } catch (e) {
      return null;
    }
  }

  /// Interval Log -- Handle the selectable field interval log
  static IntervalLog? _intervalSelectableFields(
    List<String> list,
    int logId,
    AdemType ademType,
    List<IntervalLogField> intervalFields,
    VolumeType volumeType,
  ) {
    try {
      return IntervalLog(
        logId,
        DataParser.asDate(_dateTimeFmt(list[0])),
        DataParser.asTime(_dateTimeFmt(list[1])),
        corIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[2])) ?? 0,
        uncIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[3])) ?? 0,
        avgPress: DataParser.asDouble(list[4]),
        avgTemp: DataParser.asDouble(list[5]),
        corTotalVol: _DataParser.intervalLogFields(
          IntervalLogField.corTotalVol,
          intervalFields,
          list,
          volumeType,
        ),
        uncTotalVol: _DataParser.intervalLogFields(
          IntervalLogField.uncTotalVol,
          intervalFields,
          list,
          volumeType,
        ),
        avgTotalFactor: _DataParser.intervalLogFields(
          IntervalLogField.avgTotalFactor,
          intervalFields,
          list,
          volumeType,
        ),
        uncAvgFlowRate: _DataParser.intervalLogFields(
          IntervalLogField.uncAvgFlowRate,
          intervalFields,
          list,
          volumeType,
        ),
        uncMaxFlowRate: _DataParser.intervalLogFields(
          IntervalLogField.uncMaxFlowRate,
          intervalFields,
          list,
          volumeType,
        ),
        uncMaxFlowRateTime: _DataParser.intervalLogFields(
          IntervalLogField.uncMaxFlowRateTime,
          intervalFields,
          list,
          volumeType,
        ),
        maxPress: _DataParser.intervalLogFields(
          IntervalLogField.maxPress,
          intervalFields,
          list,
          volumeType,
        ),
        maxPressTime: _DataParser.intervalLogFields(
          IntervalLogField.maxPressTime,
          intervalFields,
          list,
          volumeType,
        ),
        minPress: _DataParser.intervalLogFields(
          IntervalLogField.minPress,
          intervalFields,
          list,
          volumeType,
        ),
        minPressTime: _DataParser.intervalLogFields(
          IntervalLogField.minPressTime,
          intervalFields,
          list,
          volumeType,
        ),
        maxTemp: _DataParser.intervalLogFields(
          IntervalLogField.maxTemp,
          intervalFields,
          list,
          volumeType,
        ),
        maxTempTime: _DataParser.intervalLogFields(
          IntervalLogField.maxTempTime,
          intervalFields,
          list,
          volumeType,
        ),
        minTemp: _DataParser.intervalLogFields(
          IntervalLogField.minTemp,
          intervalFields,
          list,
          volumeType,
        ),
        minTempTime: _DataParser.intervalLogFields(
          IntervalLogField.minTempTime,
          intervalFields,
          list,
          volumeType,
        ),
        uncMinFlowRate: _DataParser.intervalLogFields(
          IntervalLogField.uncMinFlowRate,
          intervalFields,
          list,
          volumeType,
        ),
        uncMinFlowRateTime: _DataParser.intervalLogFields(
          IntervalLogField.uncMinFlowRateTime,
          intervalFields,
          list,
          volumeType,
        ),
        avgBatteryVoltage: _DataParser.intervalLogFields(
          IntervalLogField.avgBatteryVoltage,
          intervalFields,
          list,
          volumeType,
        ),
        // superXFactor: _DataParser.intervalLogFields(
        //     IntervalField.superXFactor, intervalFields, list, volumeType),
        // uncVolSinceMalf: _DataParser.intervalLogFields(
        //     IntervalField.uncVolSinceMalf, intervalFields, list, volumeType),
        alarms: _intervalLogAlarm(list.last, ademType)!,
      );
    } catch (e) {
      return null;
    }
  }

  /// Interval Log -- Handle the fixed field interval log
  static IntervalLog? _intervalFixed4Fields(
    List<String> list,
    int logId,
    AdemType ademType,
    VolumeType volumeType,
  ) {
    try {
      return IntervalLog(
        logId,
        DataParser.asDate(_dateTimeFmt(list[0])),
        DataParser.asTime(_dateTimeFmt(list[1])),
        corIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[2])) ?? 0,
        uncIncrementVol:
            volumeType.volumeMultiplier(DataParser.asNum(list[3])) ?? 0,
        avgPress: DataParser.asDouble(list[4]),
        avgTemp: DataParser.asDouble(list[5]),
        alarms: _intervalLogAlarm(list.last, ademType)!,
      );
    } catch (e) {
      return null;
    }
  }

  /// Interval Log -- Map the interval log alarm
  static IntervalLogAlarms? _intervalLogAlarm(String hexString, AdemType type) {
    try {
      // Convert hex string to int.
      final value = int.parse(hexString, radix: 16);

      // Convert int to 16-bits.
      final bits = List.generate(16, (i) => (value & (1 << i)) != 0);

      return IntervalLogAlarms(
        bits[0],
        bits[1],
        bits[2],
        type.isAdemPtz || type.isAdemPtzR || type.isAdemR || type.isAdemMi
            ? bits[4]
            : null,
        type.isAdemPtz || type.isAdemPtzR || type.isAdemR || type.isAdemMi
            ? bits[5]
            : null,
        type.isAdemS ? null : bits[6],
        type.isAdemS ? null : bits[7],
        type.isAdemTq ||
                type.isAdemPtz ||
                type.isAdemPtzq ||
                type.isAdemPtzR ||
                type.isAdemR ||
                type.isAdemMi
            ? bits[8]
            : null,
        type.isAdemTq ||
                type.isAdemPtz ||
                type.isAdemPtzq ||
                type.isAdemPtzR ||
                type.isAdemR ||
                type.isAdemMi
            ? bits[9]
            : null,
        bits[13],
        type.isAdemS ? null : bits[14],
        type.isAdemPtz || type.isAdemTq || type.isAdemPtzq ? bits[15] : null,
      );
    } catch (e) {
      return null;
    }
  }
}

class _DataParser {
  /// Event Log -- Map the event log action
  static EventLogActionType? eventLogAction(String? o) =>
      _parser(o, (o) => EventLogActionType.from(DataParser.asInt(o)!));

  /// Event Log -- Map the event log param
  static String eventLogParam(
    String data,
    Param param,
    Adem adem,
    bool is24HFmt,
  ) {
    try {
      return switch (param) {
        // NOTE: (AdEM BUG) also return #203 as Data
        Param.date =>
          DataParser.asDate(data) != null
              ? DateFormat('MMM dd, yyyy').format(DataParser.asDate(data)!)
              : data,
        Param.time || Param.gasDayStartTime =>
          DataParser.asTime(data) != null
              ? DateFormat(
                  is24HFmt ? 'HH:mm' : 'hh:mm a',
                ).format(DataParser.asTime(data)!)
              : data,
        Param.corVolUnit ||
        Param.uncVolUnit ||
        Param.corOutputPulseVolUnit ||
        Param.uncOutputPulseVolUnit => VolumeUnit.from(data)!.displayName,
        Param.pressFactorType ||
        Param.tempFactorType ||
        Param.superXFactorType => FactorType.from(data)!.displayName,
        Param.corVolDigits ||
        Param.uncVolDigits => VolDigits.from(data)!.displayName,
        Param.pressTransType => PressTransType.from(data)!.displayName,
        Param.superXAlgo => SuperXAlgo.from(data)!.displayName,
        Param.pressUnit => PressUnit.from(data)?.displayName ?? data,
        Param.tempUnit => TempUnit.from(data)!.displayName,
        Param.outPulseSpacing => OutPulseSpacing.from(data)!.displayName,
        Param.outPulseWidth => OutPulseWidth.from(data)!.displayName,
        Param.outputPulseChannel3 => PulseChannel.from(data)!.displayName,
        Param.pressureCompensationFactor1 ||
        Param.pressureCompensationFactor2 ||
        Param.pressureCompensationFactor3 ||
        Param.pressureCompensationFactor4 ||
        Param.pressureCompensationFactor5 ||
        Param.pressureCompensationFactor6 ||
        Param.pressureCompensationFactor7 ||
        Param.pressureCompensationFactor8 ||
        Param.pressureCompensationFactor9 ||
        Param.pressureCompensationFactor10 ||
        Param.pressureCompensationFactor11 ||
        Param.pressureCompensationFactor12 => DataParser.asDouble(
          data,
        )!.toStringAsFixed(6),
        Param.pushbuttonProvingMode => data,
        Param.pushbuttonOutputPulses => data,
        Param.intervalLogType => IntervalLogType.from(data)!.displayName,
        Param.intervalLogInterval => IntervalLogInterval.from(
          data,
        )!.displayName,
        Param.dispVolSelect => DispVolSelect.from(data)!.displayName,
        _ => num.tryParse(data)?.toStringAsFixed(param.decimal(adem)) ?? data,
      };
    } catch (e) {
      // NOTE: (AdEM BUG) If AdEM returns unexpected data, just show the raw data.
      return data;
    }
  }

  /// Event Log -- Create the event log header
  static EventLog eventLogHeader(List<String> dataList, int itemNumber) {
    return EventLog(
      DataParser.asInt(dataList[0])!,
      DataParser.asDate(_dateTimeFmt(dataList[2])),
      DataParser.asTime(_dateTimeFmt(dataList[3])),
      DataParser.asInt(dataList[1])!,
      itemNumber,
      null,
      'As Below',
      '-',
      '-',
      _DataParser.eventLogAction(dataList[dataList.length - 1])!,
    );
  }

  /// Event Log -- Map the event log Aga8 data
  static double eventLogAga8(Aga8Config map, Aga8Param key) {
    return switch (key) {
      Aga8Param.methane => map.methane,
      Aga8Param.nitrogen => map.nitrogen,
      Aga8Param.carbonDioxide => map.carbonDioxide,
      Aga8Param.ethane => map.ethane,
      Aga8Param.propane => map.propane,
      Aga8Param.water => map.water,
      Aga8Param.hydrogenSulphide => map.hydrogenSulphide,
      Aga8Param.hydrogen => map.hydrogen,
      Aga8Param.carbonMonoxide => map.carbonMonoxide,
      Aga8Param.oxygen => map.oxygen,
      Aga8Param.isoButane => map.isoButane,
      Aga8Param.nButane => map.nButane,
      Aga8Param.isoPentane => map.isoPentane,
      Aga8Param.nPentane => map.nPentane,
      Aga8Param.nHexane => map.nHexane,
      Aga8Param.nHeptane => map.nHeptane,
      Aga8Param.nOctane => map.nOctane,
      Aga8Param.nNonane => map.nNonane,
      Aga8Param.nDecane => map.nDecane,
      Aga8Param.helium => map.helium,
      Aga8Param.argon => map.argon,
    };
  }

  /// Event Log -- Map the event log 3 point calibration data
  static List<String>? eventLog3PtCalibra(String data, Param param, Adem adem) {
    data = data.trim();

    return [
      data.substring(0, 8),
      data.substring(8, 16),
      data.substring(16, 24),
    ].map((e) {
      final v = double.parse(e);

      final v2 = switch (param) {
        Param.threePtDpCalibParams => switch (adem.differentialPressureUnit!) {
          DiffPressUnit.inH2o => kpaToInH2o(v),
          DiffPressUnit.kpa => v,
        },
        Param.threePtPressCalibParams => switch (adem.pressUnit!) {
          PressUnit.psi => kpaToPsi(v),
          PressUnit.kpa => v,
          PressUnit.bar => kpaToBar(v),
        },
        _ => switch (adem.tempUnit!) {
          TempUnit.f => cToF(v),
          TempUnit.c => v,
        },
      };

      return v2.toStringAsFixed(param.decimal(adem));
    }).toList();
  }

  /// Alarm Log -- Map the alarm log type
  static AlarmLogType? alarmLogType(String? o) =>
      _parser(o, (o) => AlarmLogType.from(DataParser.asInt(o)!));

  /// Interval Log -- Map the interval log time
  static DateTime? intervalTime(String data) {
    var trimmedData = data.trim();
    return trimmedData != 'NA'
        ? DataParser.asTime(trimmedData.replaceAll(':', ' '))
        : null;
  }

  /// Interval Log --  Map the interval log fields
  static dynamic intervalLogFields(
    IntervalLogField field,
    List<IntervalLogField> fields,
    List<String> list,
    VolumeType volumeType,
  ) {
    final idx = fields.indexOf(field);
    if (idx != -1) {
      final value = list[idx + 6];
      return switch (fields[idx]) {
        IntervalLogField.corTotalVol => volumeType.volumeMultiplier(
          DataParser.asNum(value),
        ),
        IntervalLogField.uncTotalVol => volumeType.volumeMultiplier(
          DataParser.asNum(value),
        ),
        IntervalLogField.maxPress => DataParser.asDouble(value),
        IntervalLogField.maxPressTime => _DataParser.intervalTime(value),
        IntervalLogField.minPress => DataParser.asDouble(value),
        IntervalLogField.minPressTime => _DataParser.intervalTime(value),
        IntervalLogField.maxTemp => DataParser.asDouble(value),
        IntervalLogField.maxTempTime => _DataParser.intervalTime(value),
        IntervalLogField.minTemp => DataParser.asDouble,
        IntervalLogField.minTempTime => _DataParser.intervalTime(value),
        IntervalLogField.uncMaxFlowRate => DataParser.asNum(value),
        IntervalLogField.uncMaxFlowRateTime => _DataParser.intervalTime(value),
        IntervalLogField.uncMinFlowRate => DataParser.asNum(value),
        IntervalLogField.uncMinFlowRateTime => _DataParser.intervalTime(value),
        IntervalLogField.avgBatteryVoltage => DataParser.asDouble(value),
        IntervalLogField.avgTotalFactor => DataParser.asDouble(value),
        IntervalLogField.uncAvgFlowRate => DataParser.asNum(value),
        // IntervalField.superXFactor => DataParser.asDouble(value),
        // IntervalField.uncVolSinceMalf => DataParser.asInt(value),
        IntervalLogField.notSet => null,
      };
    } else {
      return null;
    }
  }

  /// Add catch error handler
  static T? _parser<T>(String? o, T Function(String) task) {
    try {
      if (o != null) {
        return task(o);
      } else {
        throw Exception('Cannot map: $o');
      }
    } catch (e) {
      log(e.toString(), name: 'Ble-Comm-Snd', level: 3);
      return null;
    }
  }
}

/// Add spacing the dateTime
String _dateTimeFmt(String value) {
  return value.trim().replaceAllMapped(
    RegExp(r'.{2}'),
    (e) => '${e.group(0)} ',
  );
}
