import 'package:flutter/material.dart';

import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_text.dart';

// Password format requirement
const _minLength = 8;
const _digit = 1;
const _lowercase = 1;
const _uppercase = 1;
final _digitRegex = RegExp(r'\d');
final _lowerCaseRegex = RegExp(r'[a-z]');
final _upperCaseRegex = RegExp(r'[A-Z]');
final _specialRegex = RegExp(
  r'[\~\!\@\#\$\%\^\&\*\_\-\+\=\`\|\(\)\{\}\[\]\:\;\"\<\>\,\.\?\/]',
);

class PasswordFmtDescription extends StatelessWidget {
  final String password;

  const PasswordFmtDescription({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final Set<_Fmt> failItems = {};

    // Validate the password
    if (password.length < _minLength) failItems.add(_Fmt.minLength);
    if (!_digitRegex.hasMatch(password)) failItems.add(_Fmt.digit);
    if (!_lowerCaseRegex.hasMatch(password)) failItems.add(_Fmt.lowercase);
    if (!_upperCaseRegex.hasMatch(password)) failItems.add(_Fmt.uppercase);
    if (!_specialRegex.hasMatch(password)) failItems.add(_Fmt.special);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var e in _Fmt.values)
          SText.bodySmall(
            e.text,
            color: !failItems.contains(e)
                ? colorScheme.text(context)
                : colorScheme.grey,
            softWrap: true,
          ),
      ],
    );
  }
}

enum _Fmt {
  minLength('• At least $_minLength characters'),
  digit('• At least $_digit digit'),
  lowercase('• At least $_lowercase lowercase letter'),
  uppercase('• At least $_uppercase uppercase letter'),
  special(
    '• At least $_uppercase special character (~!@#\$%^&*_-+=`|\\(){}[]:;"<>,.?/)',
  );

  final String text;

  const _Fmt(this.text);
}

bool isValidPassword(String password) {
  return password.length >= _minLength &&
      _digitRegex.hasMatch(password) &&
      _lowerCaseRegex.hasMatch(password) &&
      _upperCaseRegex.hasMatch(password) &&
      _specialRegex.hasMatch(password);
}
