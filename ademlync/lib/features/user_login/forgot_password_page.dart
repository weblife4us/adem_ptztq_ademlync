import 'dart:async';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_card.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_text_form_field.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import '../user/user_bloc.dart';
import 'password_fmt_description.dart';

const _validationCodeLength = 6;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final _bloc = BlocProvider.of<UserBloc>(context);
  final _emailTEC = TextEditingController();
  final _newPasswordTEC = TextEditingController();
  final _confirmTEC = TextEditingController();
  final _validationCodeTEC = TextEditingController();
  bool _isEmailSent = false;
  bool _isHiddenNewPassword = true;
  bool _isHiddenConfirm = true;
  String? _emailError;
  String? _confirmError;

  Timer? _countdownTimer;
  final _countdownDuration = 59;
  late int _countdown = _countdownDuration;

  String get _email => _emailTEC.text.trim();
  String get _newPassword => _newPasswordTEC.text.trim();
  String get _confirm => _confirmTEC.text.trim();
  String get _validationCode => _validationCodeTEC.text.trim();
  bool get _isCountdown => _countdownTimer?.isActive == true;

  @override
  void dispose() {
    _emailTEC.dispose();
    _newPasswordTEC.dispose();
    _confirmTEC.dispose();
    _validationCodeTEC.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isEmailSending = state is UserPwdForgetInProgress;
        final isResetting = state is UserPwdResetInProgress;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: Scaffold(
            appBar: SAppBar.withSubmit(
              context,
              text: 'Forgot Password',
              isSubmitLoading: !_isEmailSent ? isEmailSending : isResetting,
              actionText: !_isEmailSent ? 'Send' : 'Confirm',
              onPressed: !_isEmailSent
                  ? (_isValidEmail() ? _send : null)
                  : (_isValid() ? _reset : null),
            ),
            body: SmartBodyLayout(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  spacing: 4.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SText.titleLarge(
                      'Reset your password',
                      softWrap: true,
                    ),
                    SText.bodyMedium(
                      _isEmailSent
                          ? 'Check your email to retrieve a validation code'
                          : 'Input your email to receive a validation code for password reset',
                      softWrap: true,
                    ),
                  ],
                ),
                SCard.column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    STextFormField(
                      controller: _emailTEC,
                      labelText: 'Email',
                      readOnly: _isEmailSent,
                      contentPadding: const EdgeInsets.all(10.0),
                      isEnabled: !_isEmailSent && !isEmailSending,
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {
                        _emailError = null;
                      }),
                      onFieldSubmitted: _isValidEmail() ? (_) => _send() : null,
                    ),
                    if (_isEmailSent)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isEmailSending && !_isCountdown)
                            SvgImage(
                              'sent',
                              height: 20.0,
                              color: colorScheme
                                  .text(context)
                                  .withValues(alpha: _isCountdown ? 0.4 : 1.0),
                            ),
                          Flexible(
                            child: SButton.text(
                              text: _isCountdown
                                  ? 'Wait $_countdown second(s)'
                                  : 'Send Again',
                              isLoading: isEmailSending,
                              loadingSize: 16.0,
                              minimumSize: const Size(88.0, 24.0),
                              onPressed: !_isCountdown ? _send : null,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_isEmailSent)
                  SCard.column(
                    spacing: 12.0,
                    children: [
                      STextFormField(
                        controller: _validationCodeTEC,
                        labelText: 'Validation Code',
                        contentPadding: const EdgeInsets.all(10.0),
                        isEnabled: !isResetting,
                        keyboardType: TextInputType.number,
                        formatters: [
                          LengthLimitingTextInputFormatter(
                            _validationCodeLength,
                          ),
                        ],
                        textInputAction: TextInputAction.done,
                        hintText: '6 digits',
                        onChanged: (_) => setState(() {}),
                        onFieldSubmitted: _isValid() ? (_) => _reset() : null,
                      ),
                      STextFormField(
                        controller: _newPasswordTEC,
                        labelText: 'New Password',
                        contentPadding: const EdgeInsets.all(10.0),
                        isEnabled: !isResetting,
                        formatters: [
                          LengthLimitingTextInputFormatter(maxPasswordLength),
                        ],
                        obscureText: _isHiddenNewPassword,
                        onObscurePressed: () => setState(
                          () => _isHiddenNewPassword = !_isHiddenNewPassword,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {
                          _confirmError = null;
                        }),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: PasswordFmtDescription(password: _newPassword),
                        ),
                      ),
                      STextFormField(
                        controller: _confirmTEC,
                        labelText: 'Confirm',
                        contentPadding: const EdgeInsets.all(10.0),
                        isEnabled: !isResetting,
                        errorText: _confirmError,
                        formatters: [
                          LengthLimitingTextInputFormatter(maxPasswordLength),
                        ],
                        obscureText: _isHiddenConfirm,
                        onObscurePressed: () => setState(
                          () => _isHiddenConfirm = !_isHiddenConfirm,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {
                          _confirmError = null;
                        }),
                        hintText: 'Confirm password',
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserPwdForgetSuccess():
        _countDownOneMin();
        setState(() => _isEmailSent = true);
        showToast(context, text: 'Validation code sent successfully');

      case UserPwdResetSuccess():
        showToast(context, text: 'Password reset successfully');
        await context.push('/signIn');

      case UserPwdForgetFailure(:final error):
        error is DioException
            ? await showConnectivityWarning(context)
            : showToast(context, text: 'Validation code sent failed');

      case UserPwdResetFailure(:final error):
        error is DioException
            ? await showConnectivityWarning(context)
            : showToast(context, text: 'Password reset failed');
    }
  }

  void _countDownOneMin() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() {
        if (_countdown <= 1) {
          timer.cancel();
          _countdown = _countdownDuration;
        } else {
          _countdown--;
        }
      }),
    );
  }

  bool _isValidEmail() {
    return _email.isNotEmpty && _emailError == null;
  }

  bool _isValid() {
    return _newPassword.isNotEmpty &&
        _confirm.isNotEmpty &&
        _validationCode.isNotEmpty &&
        _confirmError == null;
  }

  void _send() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      if (!EmailValidator.validate(_email)) {
        _emailError = 'Wrong email format';
      }
    });

    if (_emailError == null) {
      _bloc.add(UserPwdForgot(_email));
    }
  }

  void _reset() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      if (_confirm != _newPassword) {
        _confirmError = 'Passwords do not match';
      }
    });

    if (_confirmError == null) {
      _bloc.add(UserPwdReset(_email, _newPassword, _validationCode));
    }
  }
}
