import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:ademlync_cloud/models/user_created_status.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/controllers/date_time_fmt_manager.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_dialog_layout.dart';
import '../../utils/widgets/s_permission.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import 'user_page_bloc.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late final _bloc = BlocProvider.of<UserPageBloc>(context);

  @override
  Widget build(BuildContext context) {
    final user = AppDelegate().user!;

    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (context, state) {
        final isJsonUploading = state is UserPageJsonUploadInProgress;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: Scaffold(
            appBar: const SAppBar(text: 'User'),
            body: SmartBodyLayout(
              child: Column(
                spacing: 24.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SCard(
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
                                SText.titleLarge(user.role.displayName),
                                if (!user.isLimitedUser)
                                  SText.titleMedium(user.company.toUpperCase()),
                              ],
                            ),
                            const Spacer(),
                            SText.titleSmall('# ${user.id}'),
                          ],
                        ),
                        if (!user.isLimitedUser) ...[
                          const Gap(24.0),
                          Row(
                            children: [
                              const SvgImage('mail'),
                              const Gap(10.0),
                              Expanded(
                                child: SText.bodyMedium(
                                  user.email,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8.0),
                          Row(
                            spacing: 10.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SvgImage('user_expire'),
                              SText.bodyMedium(
                                DateTimeFmtManager.formatDateTime(
                                  user.credential.tokenExpireTime,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 34.0),
                            child: SText.bodyMedium(
                              'Session Expiry (12 hours)',
                              color: colorScheme.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgImage('permission'),
                            Gap(10.0),
                            SText.bodyMedium('Permissions'),
                          ],
                        ),
                        const Gap(24.0),
                        SPermission(
                          value: UserAccess.values
                              .map((o) => o.displayName)
                              .toList(),
                          isActiveBuilder: (o) => user.permission
                              .map((o) => o.displayName)
                              .contains(o),
                        ),
                      ],
                    ),
                  ),
                  if (user.canCreateUserInCloud ||
                      (user.canEditUserInCloud || user.canDeleteUserFromCloud))
                    Column(
                      spacing: 12.0,
                      children: [
                        SButton.filled(
                          text: 'Create User',
                          onPressed: isJsonUploading
                              ? null
                              : () => context.push('/cloud/user/register'),
                        ),
                        SButton.filled(
                          text: 'Create Users from JSON',
                          isLoading: isJsonUploading,
                          onPressed: _createUsersFromJson,
                        ),
                        SButton.outlined(
                          text: 'View Users',
                          onPressed: isJsonUploading
                              ? null
                              : () => context.push('/cloud/user/manage'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _listener(BuildContext context, Object? state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserPageJsonUploadSuccess(:final status):
        final isShowDetail = await _showUploadedJsonMessage(context, status);

        if (isShowDetail == true && context.mounted) {
          await context.push('/menu/account/create-detail', extra: status);
        }
        break;

      case UserPageJsonUploadFailure(:final error):
        showToast(context, text: error.toString());
        break;
    }
  }

  Future<void> _createUsersFromJson() async {
    if (await _pickUsersJson() case final path?) {
      _bloc.add(UserPageJsonUploaded(path));
    }
  }

  Future<String?> _pickUsersJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.files.singleOrNull?.path;
  }

  Future<bool?> _showUploadedJsonMessage(
    BuildContext context,
    UserCreatedStatus status,
  ) async {
    return await showDialog(
      context: context,
      builder: (_) => CreatedUsersFromJsonMessageDialog(status: status),
    );
  }
}

class CreatedUsersFromJsonMessageDialog extends StatelessWidget {
  final UserCreatedStatus status;

  const CreatedUsersFromJsonMessageDialog({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return SDialogLayout(
      title: 'Create User from JSON',
      isShowCloseButton: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusRow('Total Users', status.total),
                _buildStatusRow('Total Groups', status.groups),
                _buildStatusRow('Users Created', status.success),
                _buildStatusRow('Users Failed', status.failure),
              ],
            ),
            const Gap(24.0),

            if (status.total > 0) ...[
              SButton.filled(
                text: 'View Detail',
                onPressed: () => Navigator.pop(context, true),
              ),
              const Gap(8.0),
            ],
            SButton.outlined(
              text: 'Close',
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 8.0,
      ), // Added horizontal padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [SText.bodyMedium('$label:'), SText.titleMedium('$value')],
      ),
    );
  }
}
