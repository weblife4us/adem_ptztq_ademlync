part of './user.dart';

@JsonSerializable()
class Group extends Equatable {
  final String rawData;
  final String company;
  @JsonKey(
    defaultValue: UserRole.limitedUser,
    unknownEnumValue: UserRole.limitedUser,
  )
  final UserRole role;

  Set<UserAccess> get permission => role.permission;

  const Group(this.rawData, this.company, this.role);

  /// Create a limited group
  factory Group.limited() => const Group('', '', UserRole.limitedUser);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);

  @override
  List<Object?> get props => [rawData, company, role];
}
