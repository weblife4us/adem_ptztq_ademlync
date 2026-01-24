import 'package:ademlync_cloud/ademlync_cloud.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_dropdown.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_permission.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_text_form_field.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import '../user/user_bloc.dart';

class UserCreatePage extends StatefulWidget {
  const UserCreatePage({super.key});

  @override
  State<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends State<UserCreatePage> {
  late final _bloc = BlocProvider.of<UserBloc>(context);
  final _emailTEC = TextEditingController();
  String? _emailError;
  List<Group>? _groups;
  Group? _group;

  String get _email => _emailTEC.text.trim();

  @override
  void initState() {
    super.initState();
    _bloc.add(UserGrpFetched());
  }

  @override
  void dispose() {
    _emailTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading = state is UserCreateInProgress;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: Scaffold(
            appBar: SAppBar.withSubmit(
              context,
              text: 'Create User',
              isSubmitLoading: isLoading,
              actionText: 'Confirm',
              onPressed: _isValid() ? _submit : null,
            ),
            body: SmartBodyLayout(
              child: _groups != null
                  ? Column(
                      spacing: 24.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgImage('mail-send'),
                                  Gap(10.0),
                                  SText.bodyMedium('Permissions'),
                                ],
                              ),
                              const Gap(10.0),
                              STextFormField(
                                controller: _emailTEC,
                                labelText: 'Email',
                                textAlign: TextAlign.left,
                                contentPadding: const EdgeInsets.all(10.0),
                                isEnabled: !isLoading,
                                errorText: _emailError,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) =>
                                    setState(() => _emailError = null),
                              ),
                              const Gap(24.0),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgImage('user_protect'),
                                  Gap(10.0),
                                  SText.bodyMedium('Assign user to...'),
                                ],
                              ),
                              const Gap(10.0),
                              SDropdownButton(
                                value: _group,
                                items: _groups!,
                                prefixString: 'Select User Group',
                                stringBuilder: (group) => group.displayName,
                                onChanged: (group) =>
                                    setState(() => _group = group!),
                              ),
                            ],
                          ),
                        ),
                        if (_group != null)
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
                                  isActiveBuilder: (o) => _group!
                                      .role
                                      .permission
                                      .map((o) => o.displayName)
                                      .contains(o),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : const SLoading(),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserGrpFetchSuccess(:final groups):
        setState(() => _groups = groups);

      case UserCreateSuccess():
        if (context.canPop()) context.pop();
        showToast(context, text: 'Create user successfully');

      case UserGrpFetchFailure(:final error):
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

      case UserCreateFailure(:final error):
        switch (error) {
          case ApiHelperError():
            handleApiHelperError(context, error);

          case DioException():
            await showConnectivityWarning(context);
            if (context.mounted && context.canPop()) context.pop();

          default:
            showToast(context, text: 'Create user failed');
        }
    }
  }

  bool _isValid() {
    return _email.isNotEmpty && _emailError == null && _group != null;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      if (!EmailValidator.validate(_email)) {
        _emailError = 'Wrong email format';
      }
    });

    if (_emailError == null) {
      _bloc.add(UserCreated(_email, _group!.rawData));
    }
  }
}
