import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../app_delegate.dart';
import '../custom_color_scheme.dart';
import 's_text.dart';

class SPinInput extends StatelessWidget {
  final TextInputType keyboardType;
  final void Function(String) onCompleted;
  final List<TextInputFormatter> inputFormatters;
  const SPinInput({
    super.key,
    this.keyboardType = TextInputType.number,
    required this.onCompleted,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      keyboardType: keyboardType,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      length: 5,
      autofocus: true,
      pinAnimationType: PinAnimationType.fade,
      defaultPinTheme: PinTheme(
        height: 38,
        textStyle: STextStyle.titleLarge.style,
      ),
      showCursor: true,
      obscureText: true,
      isCursorAnimationEnabled: false,
      cursor: _Cursor(colorScheme.accentGold(context)),
      preFilledWidget: _Cursor(colorScheme.grey),
      inputFormatters: inputFormatters,
      onCompleted: onCompleted,
    );
  }
}

class _Cursor extends StatelessWidget {
  final Color color;

  const _Cursor(this.color);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 32,
        height: 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
