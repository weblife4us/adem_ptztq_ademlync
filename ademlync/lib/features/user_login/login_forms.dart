part of './login_page.dart';

class _LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final _LoginState state;
  final bool isLoading;
  final void Function()? onForgotPwdPressed;
  final void Function(String?, String?, String?) onChanged;
  final void Function() onSubmitted;

  const _LoginForm({
    required this.formKey,
    required this.state,
    required this.isLoading,
    required this.onForgotPwdPressed,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailTEC = TextEditingController();
  final _pwdTEC = TextEditingController();
  final _totpTEC = TextEditingController();

  bool _isHidden = true;

  _LoginState get _state => widget.state;

  GlobalKey<FormState> get _formKey => widget.formKey;

  bool get _isLoading => widget.isLoading;

  void Function()? get _onForgotPwdPressed => widget.onForgotPwdPressed;

  void _onChanged(String? email, String? pwd, String? otp) {
    if (email != null) {
      setState(() {
        _pwdTEC.text = '';
        _totpTEC.text = '';
      });
    } else if (pwd != null) {
      setState(() => _totpTEC.text = '');
    }
    return widget.onChanged(email, pwd, otp);
  }

  void Function() get _onSubmitted => widget.onSubmitted;

  @override
  void dispose() {
    _emailTEC.dispose();
    _pwdTEC.dispose();
    _totpTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            STextFormField(
              controller: _emailTEC,
              labelText: 'Email',
              contentPadding: const EdgeInsets.all(10.0),
              isEnabled: !_isLoading,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.done,
              onChanged: (o) => _onChanged(o.trim(), null, null),
              validator: (o) {
                if (o == null || o.isEmpty) return 'Required';
                if (!EmailValidator.validate(o)) return 'Wrong email format';
                return null;
              },
              onFieldSubmitted: (_) => _onSubmitted(),
            ),

            if (_state == _LoginState.byPwd || _state == _LoginState.mfa) ...[
              const Gap(12.0),
              STextFormField(
                controller: _pwdTEC,
                labelText: 'Password',
                contentPadding: const EdgeInsets.all(10.0),
                isEnabled: !_isLoading,
                formatters: [
                  LengthLimitingTextInputFormatter(maxPasswordLength),
                ],
                autofillHints: const [AutofillHints.password],
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.done,
                obscureText: _isHidden,
                onObscurePressed: () => setState(() => _isHidden = !_isHidden),
                onChanged: (o) => _onChanged(null, o.trim(), null),
                validator: (o) {
                  if (o == null || o.isEmpty) return 'Required';
                  return null;
                },
                onFieldSubmitted: (_) => _onSubmitted(),
              ),
            ],

            if (_state == _LoginState.mfa) ...[
              const Gap(12.0),
              STextFormField(
                controller: _totpTEC,
                labelText: 'TOTP',
                contentPadding: const EdgeInsets.all(10.0),
                isEnabled: !_isLoading,
                formatters: [
                  LengthLimitingTextInputFormatter(maxTotpLength),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                textInputAction: TextInputAction.done,
                onChanged: (o) => _onChanged(null, null, o.trim()),
                validator: (o) {
                  if (o == null || o.isEmpty) return 'Required';
                  return null;
                },
                onFieldSubmitted: (_) => _onSubmitted(),
              ),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: SButton.text(
                text: 'Forgot Password?',
                minimumSize: Size.zero,
                onPressed: !_isLoading ? _onForgotPwdPressed : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final void Function(String, String, String) onChanged;
  final void Function() onSubmitted;

  const _SetupForm({
    required this.formKey,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<_SetupForm> {
  final _emailTEC = TextEditingController();
  final _tPwdTEC = TextEditingController();
  final _nPwdTEC = TextEditingController();
  final _cPwdTEC = TextEditingController();
  bool _isHidden = true;

  GlobalKey<FormState> get _formKey => widget.formKey;

  bool get _isLoading => widget.isLoading;

  void Function(String, String, String) get _onChanged => widget.onChanged;

  void Function() get _onSubmitted => widget.onSubmitted;

  @override
  void dispose() {
    _emailTEC.dispose();
    _tPwdTEC.dispose();
    _nPwdTEC.dispose();
    _cPwdTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            STextFormField(
              controller: _emailTEC,
              labelText: 'Email',
              textAlign: TextAlign.left,
              contentPadding: const EdgeInsets.all(10.0),
              isEnabled: !_isLoading,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (o) =>
                  _onChanged(o.trim(), _tPwdTEC.text, _nPwdTEC.text),
              validator: (o) {
                if (o == null || o.isEmpty) return 'Required';
                if (!EmailValidator.validate(o)) return 'Wrong email format';
                return null;
              },
            ),

            const Gap(12.0),
            STextFormField(
              controller: _tPwdTEC,
              labelText: 'Temporary password',
              textAlign: TextAlign.left,
              contentPadding: const EdgeInsets.all(10.0),
              isEnabled: !_isLoading,
              formatters: [LengthLimitingTextInputFormatter(maxPasswordLength)],
              textInputAction: TextInputAction.next,
              obscureText: _isHidden,
              onObscurePressed: () => setState(() => _isHidden = !_isHidden),
              onChanged: (o) =>
                  _onChanged(_emailTEC.text, o.trim(), _nPwdTEC.text),
              validator: (o) {
                if (o == null || o.isEmpty) return 'Required';
                return null;
              },
            ),

            const Gap(4.0),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 8.0),
              child: SText.bodySmall(
                'If you haven\'t received the temporary password, please request your administrator to recreate the account.',
                softWrap: true,
                color: colorScheme.grey,
              ),
            ),

            const Gap(12.0),
            STextFormField(
              controller: _nPwdTEC,
              labelText: 'New Password',
              textAlign: TextAlign.left,
              contentPadding: const EdgeInsets.all(10.0),
              isEnabled: !_isLoading,
              formatters: [LengthLimitingTextInputFormatter(maxPasswordLength)],
              autofillHints: const [AutofillHints.newPassword],
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              obscureText: _isHidden,
              onChanged: (o) =>
                  _onChanged(_emailTEC.text, _tPwdTEC.text, o.trim()),
              validator: (o) {
                if (o == null || o.isEmpty) return 'Required';
                if (o == _tPwdTEC.text) return 'Cannot match temporary one';
                if (!isValidPassword(o)) return 'Doesn\'t meet requirements';
                return null;
              },
            ),

            const Gap(6.0),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 8.0),
              child: PasswordFmtDescription(password: _nPwdTEC.text),
            ),

            const Gap(12.0),
            STextFormField(
              controller: _cPwdTEC,
              labelText: 'Confirm',
              textAlign: TextAlign.left,
              contentPadding: const EdgeInsets.all(10.0),
              isEnabled: !_isLoading,
              formatters: [LengthLimitingTextInputFormatter(maxPasswordLength)],
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              obscureText: _isHidden,
              validator: (o) {
                if (o == null || o.isEmpty) return 'Required';
                if (o != _nPwdTEC.text) return 'Passwords do not match';
                return null;
              },
              onFieldSubmitted: (_) => _onSubmitted(),
            ),
          ],
        ),
      ),
    );
  }
}
