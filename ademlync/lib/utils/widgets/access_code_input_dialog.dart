import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_delegate.dart';
import 's_dialog_layout.dart';
import 's_pin_input.dart';

@Deprecated('Use access code helper.')
Future<String?> showAccessCodeInputDialog(
  BuildContext context, {
  bool require2ndAccessCode = false,
}) async {
  return await showDialog(
    context: context,
    builder: (_) => AccessCodeInputDialog(
      require2ndAccessCode && AppDelegate().adem.isSuperAccessCodeSupported,
    ),
  );
}

class AccessCodeInputDialog extends StatelessWidget {
  final bool isSuperAccessCode;

  const AccessCodeInputDialog(this.isSuperAccessCode, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SDialogLayout(
        title: isSuperAccessCode ? 'Super Access Code' : 'Access Code',
        isShowCloseButton: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SPinInput(
            keyboardType: isSuperAccessCode
                ? TextInputType.text
                : TextInputType.number,
            inputFormatters: isSuperAccessCode
                ? []
                : [FilteringTextInputFormatter.digitsOnly],
            onCompleted: (e) {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context, e);
            },
          ),
        ),
      ),
    );
  }
}
