import 'package:ademlync_cloud/models/created_user.dart';
import 'package:ademlync_cloud/models/user_created_status.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart' show SmartBodyLayout;

class UserCreatedDetailPage extends StatefulWidget {
  final UserCreatedStatus status;

  const UserCreatedDetailPage({super.key, required this.status});

  @override
  State<UserCreatedDetailPage> createState() => _UserCreatedDetailPageState();
}

class _UserCreatedDetailPageState extends State<UserCreatedDetailPage> {
  late final _status = widget.status;

  bool _isSuccess = true;
  List<bool> _toggleValue = [true, false];

  late Map<String, List<CreatedUser>> _successfulUsers;
  late Map<String, List<CreatedUser>> _failureUsers;

  Map<String, List<CreatedUser>> get _users =>
      _isSuccess ? _successfulUsers : _failureUsers;

  @override
  void initState() {
    super.initState();
    _initUsers();

    if (_successfulUsers.isEmpty) {
      _isSuccess = false;
      _toggleValue = [false, true];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SAppBar(text: 'Detail'),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(12.0),
          ToggleButtons(
            isSelected: _toggleValue,
            onPressed: (index) {
              setState(() {
                _isSuccess = index == 0;
                _toggleValue = [index == 0, index == 1];
              });
            },
            borderRadius: BorderRadius.circular(4.0),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            color: Colors.black,
            fillColor: colorScheme.rometDKBlue(context),
            renderBorder: true,
            borderColor: colorScheme.grey,
            selectedBorderColor: colorScheme.grey,
            constraints: const BoxConstraints(minHeight: 0.0, minWidth: 0.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24.0,
                ),
                child: SText.titleMedium(
                  'Success',
                  color: _isSuccess
                      ? colorScheme.white(context)
                      : colorScheme.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24.0,
                ),
                child: SText.titleMedium(
                  'Failure',
                  color: _isSuccess
                      ? colorScheme.grey
                      : colorScheme.white(context),
                ),
              ),
            ],
          ),

          Flexible(
            child: SmartBodyLayout(
              child: _users.keys.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        final key = _users.keys.toList()[i];
                        final group = _users[key]!;

                        return SCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4.0,
                            children: [
                              SText.titleLarge(key),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (_, j) {
                                  final user = group[j];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2.0,
                                    children: [
                                      SText.bodyMedium(
                                        user.email,
                                        softWrap: true,
                                      ),
                                      if (!_isSuccess)
                                        SText.bodyMedium(
                                          ' -- ${user.message}',
                                          color: colorScheme.warning(context),
                                          softWrap: true,
                                        ),
                                    ],
                                  );
                                },
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 8.0),
                                itemCount: group.length,
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const Gap(24.0),
                      itemCount: _users.keys.length,
                    )
                  : SCard(
                      child: Container(
                        width: double.maxFinite,
                        alignment: Alignment.center,
                        child: const SText.bodyMedium('No Record'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _initUsers() {
    late final successfulUsers = <String, List<CreatedUser>>{};
    late final failureUsers = <String, List<CreatedUser>>{};

    for (final o in _status.results) {
      switch (o.status) {
        case CreatedUserStatus.success:
          successfulUsers.putIfAbsent(o.cognitoGroup, () => []);
          successfulUsers[o.cognitoGroup]!.add(o);
          break;

        case CreatedUserStatus.error:
          failureUsers.putIfAbsent(o.cognitoGroup, () => []);
          failureUsers[o.cognitoGroup]!.add(o);
          break;
      }
    }

    _successfulUsers = Map.fromEntries(
      successfulUsers.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
        ..map(
          (o) => MapEntry(
            o.key,
            o.value..sort((a, b) => a.email.compareTo(b.email)),
          ),
        ),
    );

    _failureUsers = Map.fromEntries(
      failureUsers.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
        ..map(
          (o) => MapEntry(
            o.key,
            o.value..sort((a, b) => a.email.compareTo(b.email)),
          ),
        ),
    );
  }
}
