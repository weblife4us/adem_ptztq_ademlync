part of './user.dart';

@JsonSerializable()
class Credential extends Equatable {
  @JsonKey(name: 'id_token')
  final String idToken;
  @JsonKey(name: 'access_token')
  final String accessToken;
  final int expires;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  DateTime get tokenExpireTime =>
      DateTime.fromMillisecondsSinceEpoch(expires * 1000);

  const Credential(
    this.idToken,
    this.accessToken,
    this.expires,
    this.refreshToken,
  );

  /// Create a limited credential
  factory Credential.limited() => const Credential('', '', 0, '');

  factory Credential.fromJson(Map<String, dynamic> json) =>
      _$CredentialFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialToJson(this);

  @override
  List<Object?> get props => [idToken, accessToken, expires, refreshToken];
}
