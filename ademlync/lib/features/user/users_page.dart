import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_bottom_sheet_decoration.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_dropdown.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_permission.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import 'user_bloc.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final _bloc = BlocProvider.of<UserBloc>(context);
  List<User>? _users;
  List<Group>? _groups;

  Map<String, List<User>> get _userMap {
    final res = <String, List<User>>{};

    for (final o in _users!) {
      (res[o.company] ??= []).add(o);
    }

    return res;
  }

  @override
  void initState() {
    super.initState();
    _bloc
      ..add(UserFetched())
      ..add(UserGrpFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        return Scaffold(
          appBar: const SAppBar(text: 'Users'),
          body: SmartBodyLayout(
            child: _users != null && _groups != null
                ? Column(
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_users!.isEmpty)
                        const SText.bodyMedium('No user found')
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (_, i) {
                            final o = _userMap.entries.toList()[i];

                            return Column(
                              spacing: 12.0,
                              children: [
                                if (o.value.any((o) => o.isSuperAdmin))
                                  SCard(
                                    child: _ListView(
                                      company: o.key,
                                      role: 'Super Admin',
                                      value: o.value
                                          .where((o) => o.isSuperAdmin)
                                          .toList(),
                                      onEditPressed: _edit,
                                      onRemovePressed: _remove,
                                    ),
                                  ),
                                if (o.value.any((o) => o.isAdmin))
                                  SCard(
                                    child: _ListView(
                                      company: o.key,
                                      role: 'Admin',
                                      value: o.value
                                          .where((o) => o.isAdmin)
                                          .toList(),
                                      onEditPressed: _edit,
                                      onRemovePressed: _remove,
                                    ),
                                  ),
                                if (o.value.any((o) => o.isTechnician))
                                  SCard(
                                    child: _ListView(
                                      company: o.key,
                                      role: 'Technician',
                                      value: o.value
                                          .where((o) => o.isTechnician)
                                          .toList(),
                                      onEditPressed: _edit,
                                      onRemovePressed: _remove,
                                    ),
                                  ),
                              ],
                            );
                          },
                          separatorBuilder: (_, _) => const Gap(12.0),
                          itemCount: _userMap.entries.length,
                        ),

                      // for (var o in _users!)
                      //   InkWell(
                      //     onTap: () async {
                      //       final isEdited = await context.push<bool>(
                      //         '/cloud/user/manage/edit',
                      //         extra: {
                      //           'user': o,
                      //           'groups': _groups,
                      //         },
                      //       );

                      //       if (isEdited == true) {
                      //         setState(() => _users = _groups = null);
                      //         _bloc
                      //           ..add(UBFetchUsersEvent())
                      //           ..add(UBFetchGroupsEvent());
                      //       }
                      //     },
                      //     child: SCard(
                      //       child: Column(
                      //         children: [
                      //           SDataField.string(
                      //               title: 'Company',
                      //               value: o.company.toUpperCase()),
                      //           SDataField.string(
                      //               title: 'Role', value: o.role.displayName),
                      //           SDataField.string(
                      //               title: 'Email', value: o.email),
                      //         ],
                      //       ),
                      //     ),
                      //   )
                    ],
                  )
                : const SLoading(),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserFetchSuccess(:final users):
        setState(() => _users = users);

      case UserGrpFetchSuccess(:final groups):
        setState(() => _groups = groups);

      case UserGrpFetchFailure(:final error):
      case UserFetchFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);
            if (context.mounted && context.canPop()) context.pop();

          default:
            await handleError(context, error);
            if (context.mounted && context.canPop()) context.pop();
        }
    }
  }

  Future<void> _edit(User user) async {
    final isEdited = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _EditBottomSheet(user: user, groups: _groups!);
      },
    );

    if (isEdited == true) {
      setState(() => _users = _groups = null);
      _bloc
        ..add(UserFetched())
        ..add(UserGrpFetched());
    }
  }

  Future<void> _remove(User user) async {
    final isRemoved = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      builder: (_) {
        return _RemoveBottomSheet(user: user);
      },
    );

    if (isRemoved == true) {
      setState(() => _users = _groups = null);
      _bloc
        ..add(UserFetched())
        ..add(UserGrpFetched());
    }
  }
}

class _ListView extends StatelessWidget {
  final String company;
  final String role;
  final List<User> value;
  final void Function(User) onEditPressed;
  final void Function(User) onRemovePressed;

  const _ListView({
    required this.company,
    required this.role,
    required this.value,
    required this.onEditPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SText.titleLarge(company.toUpperCase()),
        SText.titleMedium(role, color: colorScheme.grey),
        const Gap(24.0),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            final user = value.toList()[i];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SText.bodyMedium(user.email, softWrap: true)),
                const Gap(24.0),
                InkWell(
                  onTap: () => onEditPressed(user),
                  child: SvgImage('edit', color: colorScheme.text(context)),
                ),
                const Gap(12.0),
                InkWell(
                  onTap: () => onRemovePressed(user),
                  child: SvgImage('delete', color: colorScheme.text(context)),
                ),
              ],
            );
          },
          separatorBuilder: (_, _) => const Gap(12.0),
          itemCount: value.length,
        ),
      ],
    );
  }
}

class _EditBottomSheet extends StatefulWidget {
  final User user;
  final List<Group> groups;

  const _EditBottomSheet({required this.user, required this.groups});

  @override
  State<_EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<_EditBottomSheet> {
  final _bloc = UserBloc();

  late final _user = widget.user;
  late final _groups = widget.groups;
  late Group _group = _user.group;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        return SBottomSheetDecoration(
          header: 'Edit User',
          text:
              'Please confirm your decision to edit the user, as this action cannot be undone',
          child: Column(
            spacing: 24.0,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 12.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SText.titleLarge(_user.role.displayName),
                      if (!_user.isLimitedUser)
                        SText.titleMedium(_user.company.toUpperCase()),
                    ],
                  ),
                  const Spacer(),
                  SText.titleSmall('# ${_user.id}'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SvgImage('mail'),
                  const Gap(10.0),
                  SText.bodyMedium(_user.email),
                ],
              ),
              SDropdownButton(
                value: _group,
                items: _groups,
                prefixString: 'Select User Group',
                stringBuilder: (o) => o.displayName,
                onChanged: (o) => setState(() => _group = o!),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.subCardBackground(context),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SPermission(
                  value: UserAccess.values.map((o) => o.displayName).toList(),
                  isActiveBuilder: (o) => _group.role.permission
                      .map((o) => o.displayName)
                      .contains(o),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SButton.outlined(
                      text: 'Close',
                      onPressed: state is UserUpdateInProgress
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  const Gap(12.0),
                  Expanded(
                    child: SButton.filled(
                      text: 'Confirm',
                      isLoading: state is UserUpdateInProgress,
                      onPressed: state is UserUpdateInProgress ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserUpdateSuccess():
        Navigator.pop(context, true);
        showToast(context, text: 'Update user successfully');

      case UserUpdateFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);

          default:
            showToast(context, text: 'Update user failed');
        }
    }
  }

  void _submit() {
    _bloc.add(UserUpdated(_user.email, _group.rawData));
  }
}

class _RemoveBottomSheet extends StatefulWidget {
  final User user;

  const _RemoveBottomSheet({required this.user});

  @override
  State<_RemoveBottomSheet> createState() => _RemoveBottomSheetState();
}

class _RemoveBottomSheetState extends State<_RemoveBottomSheet> {
  final _bloc = UserBloc();

  late final _user = widget.user;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        return SBottomSheetDecoration(
          header: 'Remove User',
          text:
              'Please confirm your decision to remove the user, as this action cannot be undone',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 12.0,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SText.titleLarge(_user.role.displayName),
                      if (!_user.isLimitedUser)
                        SText.titleMedium(_user.company.toUpperCase()),
                    ],
                  ),
                  const Spacer(),
                  SText.titleSmall('# ${_user.id}'),
                ],
              ),
              const Gap(24.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SvgImage('mail'),
                  const Gap(10.0),
                  SText.bodyMedium(_user.email),
                ],
              ),
              const Gap(24.0),
              Row(
                children: [
                  Expanded(
                    child: SButton.outlined(
                      text: 'Close',
                      onPressed: state is UserDeleteInProgress
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  const Gap(12.0),
                  Expanded(
                    child: SButton.filled(
                      text: 'Confirm',
                      isLoading: state is UserDeleteInProgress,
                      onPressed: state is UserDeleteInProgress ? null : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserDeleteSuccess():
        Navigator.pop(context, true);
        showToast(context, text: 'Remove user successfully');

      case UserDeleteFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);

          default:
            showToast(context, text: 'Remove user failed');
        }
    }
  }

  void _submit() {
    _bloc.add(UserDeleted(_user.email));
  }
}
