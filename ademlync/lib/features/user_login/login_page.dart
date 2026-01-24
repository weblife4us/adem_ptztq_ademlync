import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../utils/app_delegate.dart';
import '../../utils/constants.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/functions.dart';
import '../../utils/widgets/s_button.dart';
import '../../utils/widgets/s_image.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/s_text_form_field.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../user/user_bloc.dart';
import 'password_fmt_description.dart';

part 'login_forms.dart';

class LoginPage extends StatefulWidget {
  final bool? isCredExpired;

  const LoginPage({super.key, required this.isCredExpired});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final _bloc = BlocProvider.of<UserBloc>(context);

  late final _isCredExpired = widget.isCredExpired ?? false;

  final _loginFormKey = GlobalKey<FormState>();
  final _setupFormKey = GlobalKey<FormState>();

  _LoginType? _loginType;
  _LoginState? _loginState;

  String? _email;
  String? _pwd;
  String? _totp;
  String? _session;
  String? _tempPwd;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isCredExpired) _showExpiredAlert();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: _listener,
      builder: (_, state) {
        final isLoading =
            state is UserLoginInProgressed ||
            state is UserIdpDiscoverInProgressed ||
            state is UserMfaChallengeInProgressed;

        return GestureDetector(
          onTap: dismissKeyboard,
          child: Scaffold(
            body: SmartBodyLayout(
              spacing: 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 12.0,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SImage.logo(color: colorScheme.logo(context)),
                        ),
                        _Description(type: _loginType),
                      ],
                    ),

                    const Gap(32.0),
                    AnimatedOpacity(
                      opacity: _loginType == null ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        clipBehavior: Clip.antiAlias,
                        alignment: AlignmentDirectional.topCenter,
                        child: SizedBox(
                          height: _loginType != null ? null : 0.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: switch (_loginType) {
                              _LoginType.login => _LoginForm(
                                formKey: _loginFormKey,
                                state: _loginState!,
                                isLoading: isLoading,
                                onForgotPwdPressed: _pushToForgotPwdPage,
                                onChanged: _updateLoginData,
                                onSubmitted: _login,
                              ),
                              _LoginType.setup => _SetupForm(
                                formKey: _setupFormKey,
                                isLoading: isLoading,
                                onChanged: _updateSetupData,
                                onSubmitted: _firstTimeLogin,
                              ),
                              _ => null,
                            },
                          ),
                        ),
                      ),
                    ),

                    const Gap(24.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        spacing: 8.0,
                        children: [
                          if (_errorMsg case final error?)
                            SText.bodySmall(
                              error,
                              color: colorScheme.warning(context),
                            ),

                          if (_loginType == null) ...[
                            SButton.filled(
                              text: 'Existing User',
                              onPressed: _changeToLogin,
                            ),

                            SButton.filled(
                              text: 'First-Time Login',
                              onPressed: _changeToSetup,
                            ),

                            SButton.outlined(
                              text: 'Continue as Guest',
                              onPressed: _loginAsLimitedUser,
                            ),
                          ] else ...[
                            SButton.filled(
                              text: 'Login',
                              isLoading: isLoading,
                              onPressed: !isLoading
                                  ? switch (_loginType) {
                                      _LoginType.login => _login,
                                      _LoginType.setup => _firstTimeLogin,
                                      _ => null,
                                    }
                                  : null,
                            ),

                            SButton.outlined(
                              text: 'Other Options',
                              onPressed: !isLoading ? _resetState : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _listener(BuildContext context, Object state) async {
    if (!context.mounted) return;

    switch (state) {
      case UserIdpDiscoverSuccess():
        setState(() => _loginState = _LoginState.byPwd);

      case UserLoginSuccess():
      case UserNewLoginSuccess():
        TextInput.finishAutofillContext(shouldSave: true);
        _goToDashboard();

      case UserLimitedLoginSuccess():
        _goToDashboard();

      case UserMfaRequired(:final session):
        setState(() {
          _loginState = _LoginState.mfa;
          _session = session;
        });

      case UserMfaChallengeSuccess():
        _goToDashboard();

      case UserMfaChallengeFailure(:final error):
        error is DioException
            ? await showConnectivityWarning(context)
            : setState(() => _errorMsg = 'TOTP is incorrect');

      case UserLoginFailure(:final error):
      case UserNewLoginFailure(:final error):
        error is DioException
            ? await showConnectivityWarning(context)
            : setState(() => _errorMsg = 'Email / Password is incorrect');

      case UserLimitedLoginFailure(:final error):
        error is DioException
            ? await showConnectivityWarning(context)
            : setState(() => _errorMsg = 'Unknown error');
    }
  }

  void _changeToLogin() {
    setState(() => _loginType = _LoginType.login);
    _loginState = _LoginState.discoverIdp;
  }

  void _changeToSetup() => setState(() => _loginType = _LoginType.setup);

  void _resetState() => setState(() {
    _loginType = null;
    _loginState = null;
    _errorMsg = null;
    _email = null;
    _pwd = null;
    _totp = null;
    _session = null;
    _tempPwd = null;
    _loginFormKey.currentState?.reset();
    _setupFormKey.currentState?.reset();
  });

  void _updateLoginData(String? email, String? pwd, String? otp) =>
      setState(() {
        _errorMsg = null;

        if (email != null) {
          _email = email;
          _pwd = null;
          _totp = null;
          _session = null;
          _loginState = _LoginState.discoverIdp;
        } else if (pwd != null) {
          _pwd = pwd;
          _totp = null;
          _session = null;
          _loginState = _LoginState.byPwd;
        } else {
          _totp = otp;
          if (_totp?.length == maxTotpLength) {
            _bloc.add(UserMfaChallenged(_email!, _totp!, _session!));
          }
        }
      });

  void _updateSetupData(String email, String temPwd, String newPwd) =>
      setState(() {
        _email = email;
        _tempPwd = temPwd;
        _pwd = newPwd;
      });

  bool _isLoginFormValid() => _loginFormKey.currentState?.validate() ?? false;

  bool _isSetupFormValid() => _setupFormKey.currentState?.validate() ?? false;

  void _login() {
    if (!_isLoginFormValid()) return;

    switch (_loginState) {
      case _LoginState.discoverIdp:
        _bloc.add(UserIdpDiscovered(_email!));

      case _LoginState.byPwd:
        _bloc.add(UserLoggedIn(_email!, _pwd!));

      case _LoginState.mfa:
        _bloc.add(UserMfaChallenged(_email!, _totp!, _session!));

      case _:
    }
  }

  void _firstTimeLogin() {
    if (!_isSetupFormValid()) return;
    _bloc.add(UserNewLoggedIn(_email!, _tempPwd!, _pwd!));
  }

  void _loginAsLimitedUser() => _bloc.add(UserLimitedLoggedIn());

  Future<void> _showExpiredAlert() => showWarningDialog(
    context,
    title: 'Login Expired',
    detail: 'Please login again',
  );

  Future<void> _pushToForgotPwdPage() => context.push('/signIn/forgotPassword');

  void _goToDashboard() => context.go('/setup', extra: true);
}

class _Description extends StatelessWidget {
  final _LoginType? type;

  const _Description({required this.type});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        key: UniqueKey(),
        spacing: 6.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          SText.titleLarge(
            switch (type) {
              _LoginType.login => 'Access Your Account',
              _LoginType.setup => 'Set Your New Password',
              _ => 'Welcome to our platform',
            },
            textAlign: TextAlign.left,
            softWrap: true,
          ),

          SText.titleMedium(
            switch (type) {
              _LoginType.login =>
                'Please proceed to log in to access your account',
              _LoginType.setup => 'Kindly set a new password for access',
              _ => 'Discover Efficient AdEM Management',
            },
            textAlign: TextAlign.left,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}

enum _LoginType { login, setup }

enum _LoginState { discoverIdp, byPwd, mfa }
