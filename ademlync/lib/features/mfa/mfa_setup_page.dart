import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_icon.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_text_form_field.dart';
import 'mfa_bloc.dart';

class MfaSetupPage extends StatefulWidget {
  final String setupKey;

  const MfaSetupPage({super.key, required this.setupKey});

  @override
  State<MfaSetupPage> createState() => _MfaSetupPageState();
}

class _MfaSetupPageState extends State<MfaSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late final _bloc = BlocProvider.of<MfaBloc>(context);

  late final _setupKey = widget.setupKey;
  String? _errorMsg;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (context, state) {
        final isLoading = state is MfaVerifyInProgress;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: Scaffold(
            appBar: const SAppBar(text: 'MFA Setup'),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36.0,
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SText.titleMedium('Scan QR Code'),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: SText.bodyMedium(
                          '• Open your authenticator app',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: SText.bodyMedium('• Tap “+” → Scan QR code'),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: SText.bodyMedium(
                          '• Point camera at the code below',
                        ),
                      ),

                      const Gap(12.0),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.white(context),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox.square(
                            dimension: 164.0,
                            child: PrettyQrView.data(data: _setupKey),
                          ),
                        ),
                      ),

                      const Gap(48.0),
                      const SText.titleMedium(
                        'Can\'t scan or using single device?',
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: SText.bodyMedium(
                          '• Tap “Enter key manually” in your app',
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: SText.bodyMedium(
                          '• Copy and paste this setup key:',
                        ),
                      ),

                      const Gap(12.0),
                      InkWell(
                        onTap: _copySecretKey,
                        child: Row(
                          spacing: 12.0,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SText.titleMedium(
                                _setupKey,
                                softWrap: true,
                              ),
                            ),

                            SIcon(
                              Icons.copy_all_rounded,
                              color: colorScheme.text(context),
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),

                      const Gap(48.0),
                      SText.bodySmall(
                        'After adding the account, open the app and enter the current 6-digit code below.',
                        color: colorScheme.grey,
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),

                      const Gap(12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: STextFormField(
                          controller: _controller,
                          hintText: 'Enter 6-digit code',
                          isEnabled: !isLoading,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          readOnly: isLoading,
                          errorText: _errorMsg,
                          formatters: [
                            LengthLimitingTextInputFormatter(6),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (o) {
                            if (o == null || o.isEmpty) return 'Required';
                            return null;
                          },
                          onChanged: (_) {
                            setState(() => _errorMsg = null);
                            if (_controller.text.length == maxTotpLength &&
                                !isLoading) {
                              _verifyMfa();
                            }
                          },
                          onFieldSubmitted: !isLoading
                              ? (_) => _verifyMfa()
                              : null,
                        ),
                      ),

                      const Gap(12.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: SButton.filled(
                          text: 'Setup',
                          isLoading: isLoading,
                          onPressed: !isLoading ? _verifyMfa : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) {
    if (!context.mounted) return;

    switch (state) {
      case MfaVerifySuccess():
        showToast(context, text: 'MFA setup success');
        _goToDashboard();

      case MfaVerifyFailure():
        setState(() => _errorMsg = '6-digit code incorrect');
    }
  }

  Future<void> _copySecretKey() async {
    await Clipboard.setData(ClipboardData(text: _setupKey));
    if (mounted) showToast(context, text: 'Secret key copied to clipboard');
  }

  void _verifyMfa() {
    dismissKeyboard();

    if (_formKey.currentState?.validate() != true) return;

    final user = AppDelegate().user ?? (throw Exception('User not found.'));
    _bloc.add(MfaVerified(user.email, _controller.text));
  }

  void _goToDashboard() => context
    ..pop()
    ..pop();
}
