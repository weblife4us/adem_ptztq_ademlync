import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'created_user.dart';

part 'user_created_status.g.dart';

@JsonSerializable(createToJson: false, fieldRename: FieldRename.snake)
class UserCreatedStatus extends Equatable {
  @JsonKey(defaultValue: 'Unknown Status')
  final String message;
  @JsonKey(name: 'total_users', defaultValue: 0)
  final int total;
  @JsonKey(name: 'successful_users', defaultValue: 0)
  final int success;
  @JsonKey(name: 'failed_users', defaultValue: 0)
  final int failure;
  @JsonKey(name: 'groups_processed', defaultValue: 0)
  final int groups;
  @JsonKey(defaultValue: <CreatedUser>[])
  final List<CreatedUser> results;

  const UserCreatedStatus(
    this.message,
    this.total,
    this.success,
    this.failure,
    this.groups,
    this.results,
  );

  List<CreatedUser> get successfulUser =>
      results.where((o) => o.status == CreatedUserStatus.success).toList();

  List<CreatedUser> get failureUser =>
      results.where((o) => o.status == CreatedUserStatus.success).toList();

  factory UserCreatedStatus.fromJson(Map<String, dynamic> json) =>
      _$UserCreatedStatusFromJson(json);

  @override
  List<Object?> get props => [
    message,
    total,
    success,
    failure,
    groups,
    results,
  ];
}
