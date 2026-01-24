import 'dart:async';

class STimer {
  final int sec;
  final void Function() func;
  Timer? _timer;

  STimer(this.func, {this.sec = 1});

  /// Starts the `timer` with the [interval].
  void start() {
    // Stop previous timer if any
    stop();

    // Trigger the function
    func();

    // Loop the function with duration
    _timer = Timer.periodic(Duration(seconds: sec), (_) async => func());
  }

  /// Stops the `timer` if it's running.
  void stop() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
