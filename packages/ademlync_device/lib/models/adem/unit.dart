part of 'adem.dart';

class Unit extends Equatable {
  final String serialNumber;
  final String? serialNumberPart2;
  final String? productType;
  final String firmwareVersion;
  final String? firmwareChecksum;
  final String siteName;
  final String siteAddress;
  final String customerId;
  final DateTime date;
  final DateTime time;

  const Unit(
    this.serialNumber,
    this.serialNumberPart2,
    this.productType,
    this.firmwareVersion,
    this.firmwareChecksum,
    this.siteName,
    this.siteAddress,
    this.customerId,
    this.date,
    this.time,
  );

  @override
  List<Object?> get props => [serialNumber];

  AdemType get type => AdemType.from(firmwareVersion, productType);

  /// Determine if the AdEM support a super access code
  bool get isSuperAccessCodeSupported =>
      type.isSuperAccessCodeSupported(firmwareVersion);

  /// Determine if the AdEM support a 2nd serial number
  bool get isSerialNumberPart2Supported =>
      type.isSerialNumberPart2Supported(firmwareVersion);
}
