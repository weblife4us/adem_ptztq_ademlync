import 'package:ademlync_device/ademlync_device.dart';
import 'package:equatable/equatable.dart';

class SetupAga8DetailPageModel extends Equatable {
  final Map<Aga8Param, double> percentiles;

  const SetupAga8DetailPageModel(this.percentiles);

  SetupAga8DetailPageModel.from(Aga8Config list)
    : percentiles = {
        Aga8Param.methane: list.methane,
        Aga8Param.nitrogen: list.nitrogen,
        Aga8Param.carbonDioxide: list.carbonDioxide,
        Aga8Param.ethane: list.ethane,
        Aga8Param.propane: list.propane,
        Aga8Param.water: list.water,
        Aga8Param.hydrogenSulphide: list.hydrogenSulphide,
        Aga8Param.hydrogen: list.hydrogen,
        Aga8Param.carbonMonoxide: list.carbonMonoxide,
        Aga8Param.oxygen: list.oxygen,
        Aga8Param.isoButane: list.isoButane,
        Aga8Param.nButane: list.nButane,
        Aga8Param.isoPentane: list.isoPentane,
        Aga8Param.nPentane: list.nPentane,
        Aga8Param.nHexane: list.nHexane,
        Aga8Param.nHeptane: list.nHeptane,
        Aga8Param.nOctane: list.nOctane,
        Aga8Param.nNonane: list.nNonane,
        Aga8Param.nDecane: list.nDecane,
        Aga8Param.helium: list.helium,
        Aga8Param.argon: list.argon,
      };

  SetupAga8DetailPageModel copyWith({Map<Aga8Param, double>? percentiles}) =>
      SetupAga8DetailPageModel(percentiles ?? this.percentiles);

  @override
  List<Object?> get props => [percentiles];
}
