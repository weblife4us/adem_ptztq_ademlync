import 'package:equatable/equatable.dart';

class PushButtonModule extends Equatable {
  /// Proving and pulses output functions
  final bool? isProvingPulsesEnabled;

  const PushButtonModule({required this.isProvingPulsesEnabled});

  PushButtonModule copyWith({bool? isProvingPulsesEnabled}) => PushButtonModule(
    isProvingPulsesEnabled:
        isProvingPulsesEnabled ?? this.isProvingPulsesEnabled,
  );

  @override
  List<Object?> get props => [isProvingPulsesEnabled];
}
