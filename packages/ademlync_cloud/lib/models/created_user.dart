import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'created_user.g.dart';

@JsonSerializable(createToJson: false)
class CreatedUser extends User {
  final CreatedUserStatus status;
  final String message;

  const CreatedUser(super.email, super.group, this.status, this.message);

  factory CreatedUser.fromJson(Map<String, dynamic> json) =>
      _$CreatedUserFromJson(json);

  @override
  List<Object?> get props => [email, group, status, message];
}

@JsonEnum()
enum CreatedUserStatus { success, error }
