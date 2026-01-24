part of 'calibration.dart';

class Calib3PtConfig {
  final double lowPtOffset;
  final double midPtOffset;
  final double highPtOffset;
  final int adCountsLow;
  final int adCountsMid;
  final int adCountsHigh;

  const Calib3PtConfig(
    this.lowPtOffset,
    this.adCountsLow,
    this.midPtOffset,
    this.adCountsMid,
    this.highPtOffset,
    this.adCountsHigh,
  );

  /// Substring and map 3 point calibration values
  factory Calib3PtConfig.from(String data) {
    if (data.length != 48) throw Exception('3PtCalParam is wrong length.');

    final list = [
      for (int i = 0; i < data.length; i += 8) data.substring(i, i + 8),
    ];

    return Calib3PtConfig(
      _offsetParse(list[0]),
      int.parse(list[1]),
      _offsetParse(list[2]),
      int.parse(list[3]),
      _offsetParse(list[4]),
      int.parse(list[5]),
    );
  }

  /// Calculate low point A/D slop
  double get lowPtADSlop =>
      _calculateADSlop(midPtOffset, lowPtOffset, adCountsMid, adCountsLow);

  /// Calculate high point A/D slop
  double get highPtADSlop =>
      _calculateADSlop(highPtOffset, midPtOffset, adCountsHigh, adCountsMid);

  /// Convert to display value -- Dp
  Calib3PtConfig fromKpaToDpUnit(MeterSystem system) {
    return switch (system) {
      MeterSystem.imperial => copyWith(
        lowPtOffset: kpaToInH2o(lowPtOffset) / dpCalibOffset,
        midPtOffset: kpaToInH2o(midPtOffset) / dpCalibOffset,
        highPtOffset: kpaToInH2o(highPtOffset) / dpCalibOffset,
      ),
      MeterSystem.metric => copyWith(
        lowPtOffset: lowPtOffset / dpCalibOffset,
        midPtOffset: midPtOffset / dpCalibOffset,
        highPtOffset: highPtOffset / dpCalibOffset,
      ),
    };
  }

  /// Convert back to origan value -- Dp
  Calib3PtConfig fromDpUnitToKpa(MeterSystem system) {
    return switch (system) {
      MeterSystem.imperial => copyWith(
        lowPtOffset: inH2oToKpa(lowPtOffset) * dpCalibOffset,
        midPtOffset: inH2oToKpa(midPtOffset) * dpCalibOffset,
        highPtOffset: inH2oToKpa(highPtOffset) * dpCalibOffset,
      ),
      MeterSystem.metric => copyWith(
        lowPtOffset: lowPtOffset * dpCalibOffset,
        midPtOffset: midPtOffset * dpCalibOffset,
        highPtOffset: highPtOffset * dpCalibOffset,
      ),
    };
  }

  /// Convert to display value -- Press
  Calib3PtConfig fromKpaToPressUnit(PressUnit unit) {
    return switch (unit) {
      PressUnit.psi => copyWith(
        lowPtOffset: kpaToPsi(lowPtOffset),
        midPtOffset: kpaToPsi(midPtOffset),
        highPtOffset: kpaToPsi(highPtOffset),
      ),
      PressUnit.kpa => this,
      PressUnit.bar => copyWith(
        lowPtOffset: kpaToBar(lowPtOffset),
        midPtOffset: kpaToBar(midPtOffset),
        highPtOffset: kpaToBar(highPtOffset),
      ),
    };
  }

  /// Convert back to origan value -- Press
  Calib3PtConfig fromPressUnitToKpa(PressUnit unit) {
    return switch (unit) {
      PressUnit.psi => copyWith(
        lowPtOffset: psiaToKpa(lowPtOffset),
        midPtOffset: psiaToKpa(midPtOffset),
        highPtOffset: psiaToKpa(highPtOffset),
      ),
      PressUnit.kpa => this,
      PressUnit.bar => copyWith(
        lowPtOffset: barToKpa(lowPtOffset),
        midPtOffset: barToKpa(midPtOffset),
        highPtOffset: barToKpa(highPtOffset),
      ),
    };
  }

  /// Convert to display value -- Temp
  Calib3PtConfig fromCToTempUnit(TempUnit unit) {
    return switch (unit) {
      TempUnit.f => copyWith(
        lowPtOffset: cToF(lowPtOffset),
        midPtOffset: cToF(midPtOffset),
        highPtOffset: cToF(highPtOffset),
      ),
      TempUnit.c => this,
    };
  }

  /// Convert back to origan value -- Temp
  Calib3PtConfig fromTempUnitToC(TempUnit unit) {
    return switch (unit) {
      TempUnit.f => copyWith(
        lowPtOffset: fToC(lowPtOffset),
        midPtOffset: fToC(midPtOffset),
        highPtOffset: fToC(highPtOffset),
      ),
      TempUnit.c => this,
    };
  }

  Calib3PtConfig copyWith({
    double? lowPtOffset,
    double? midPtOffset,
    double? highPtOffset,
  }) => Calib3PtConfig(
    lowPtOffset ?? this.lowPtOffset,
    adCountsLow,
    midPtOffset ?? this.midPtOffset,
    adCountsMid,
    highPtOffset ?? this.highPtOffset,
    adCountsHigh,
  );

  /// Map to adem fmt
  String toDataString(Calib3PtConfig oldParams, {int? decimal}) {
    final offsetA = _calculateOffset(
      oldParams.lowPtOffset,
      oldParams.adCountsLow,
      oldParams.lowPtADSlop,
      adCountsLow,
    );
    final offsetB = _calculateOffset(
      oldParams.midPtOffset,
      oldParams.adCountsMid,
      oldParams.highPtADSlop,
      adCountsMid,
    );
    final offsetC = _calculateOffset(
      oldParams.highPtOffset,
      oldParams.adCountsHigh,
      oldParams.highPtADSlop,
      adCountsHigh,
    );

    return (StringBuffer()
          ..write(_convert8LenString(lowPtOffset, decimal ?? 1))
          ..write(_convert8LenString(adCountsLow, 0))
          ..write(_convert8LenString(midPtOffset, decimal ?? 1))
          ..write(_convert8LenString(adCountsMid, 0))
          ..write(_convert8LenString(highPtOffset, decimal ?? 1))
          ..write(_convert8LenString(adCountsHigh, 0))
          ..write(_convert8LenString(lowPtADSlop, 4))
          ..write(_convert8LenString(highPtADSlop, 4))
          ..write(_convert8LenString(offsetA, decimal ?? 1))
          ..write(_convert8LenString(offsetB, decimal ?? 1))
          ..write(_convert8LenString(offsetC, decimal ?? 1)))
        .toString();
  }
}

/// Fill 0 to fit 8 length
String _convert8LenString(num n, int decimal) {
  return n.toStringAsFixed(decimal).padLeft(8, '0');
}

/// Handle a negative value
double _offsetParse(String date) => date.contains('-')
    ? double.parse(date.replaceAll('-', '')) * -1
    : double.parse(date);

/// Calculate a slop offset
double _calculateADSlop(
  double highPointOffset,
  double lowPointOffset,
  int highPointAdCounts,
  int lowPointAdCounts,
) {
  return (highPointOffset - lowPointOffset) /
      (highPointAdCounts - lowPointAdCounts);
}

/// Calculate a offset
double _calculateOffset(
  double oldOffset,
  int oldAdCounts,
  double oldAdSlop,
  int newAdCounts,
) {
  return oldOffset + (newAdCounts - oldAdCounts) * oldAdSlop;
}
