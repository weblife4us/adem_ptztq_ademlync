import 'dart:collection';
import 'dart:math';

import 'package:ademlync_device/ademlync_device.dart';

const _maxCounts = 3;
const _queueLength = 5;

mixin CalibrationManager {
  final Queue<int> _queue = Queue.from(List.generate(_queueLength, (_) => 0));

  /// Determine the A/D reading counts stability.
  bool isADRCStable(int counts) {
    // Queue the new A/D reading counts
    _queue
      ..removeFirst()
      ..addLast(counts);

    return _queue.reduce(max) - _queue.reduce(min) <= _maxCounts;
  }

  // Determine valid 3 point calibration config
  bool isValidCalib3PtConfig(Calib3PtConfig config) {
    return _isValidADReadCounts(config.adCountsMid, config.adCountsLow) &&
        _isValidADReadCounts(config.adCountsHigh, config.adCountsMid) &&
        _isValidADSlop(config.lowPtADSlop) &&
        _isValidADSlop(config.highPtADSlop);
  }

  /// Determine valid A/D reading counts.
  bool _isValidADReadCounts(int countsA, int countsB) {
    return countsA - countsB >= 100;
  }

  /// Determine valid A/D slop.
  bool _isValidADSlop(double slop) {
    return slop > 0 && slop < 1000;
  }
}
