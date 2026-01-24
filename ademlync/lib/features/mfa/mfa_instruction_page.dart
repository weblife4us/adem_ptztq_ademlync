import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_image.dart';
import '../../utils/widgets/s_text.dart';
import 'mfa_bloc.dart';

class MfaInstructionPage extends StatefulWidget {
  const MfaInstructionPage({super.key});

  @override
  State<MfaInstructionPage> createState() => _MfaInstructionPageState();
}

class _MfaInstructionPageState extends State<MfaInstructionPage> {
  late final _bloc = BlocProvider.of<MfaBloc>(context);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (context, state) {
        final isLoading = state is MfaEnableInProgress;

        return Scaffold(
          appBar: const SAppBar(text: 'MFA Setup'),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 36.0,
              horizontal: 24.0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: SImage.logo(color: colorScheme.logo(context)),
                  ),

                  const Gap(12.0),
                  const SText.titleMedium(
                    'Multi-Factor Authentication (MFA) is now required to keep your ROMET account secure.',
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),

                  const Gap(48.0),
                  const SText.bodyMedium(
                    'We recommend an authenticator app (Google Authenticator, Microsoft Authenticator, etc.). You’ll enter a 6-digit code from the app every time you log in.',
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: SButton.filled(
                      text: 'Start Setup',
                      isLoading: isLoading,
                      onPressed: !isLoading ? _enableMfa : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case MfaEnableSuccess(:final setupKey):
        await _pushToSetupPage(setupKey);
    }
  }

  void _enableMfa() {
    if (AppDelegate().user case final user?) {
      _bloc.add(MfaEnabled(user.email));
    }
  }

  Future<void> _pushToSetupPage(String setupKey) =>
      context.push('/mfa/setup', extra: setupKey);
}
